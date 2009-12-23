From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [TCP]: min_t/max_t confusion in tcp_select_initial_window()?
Date: Wed, 23 Dec 2009 23:23:11 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912232321090.10866@melkinpaasi.cs.helsinki.fi>
References: <4B3179B8.5000403@gmail.com> <20091222.194747.193724694.davem@davemloft.net> <alpine.DEB.2.00.0912232140500.10866@melkinpaasi.cs.helsinki.fi> <20091223.131526.193724825.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696230645-1345756015-1261603295=:10866"
Cc: roel.kluin@gmail.com, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56746 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757237AbZLWVXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 16:23:14 -0500
In-Reply-To: <20091223.131526.193724825.davem@davemloft.net>
Content-ID: <alpine.DEB.2.00.0912232322550.10866@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-1345756015-1261603295=:10866
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0912232321481.10866@melkinpaasi.cs.helsinki.fi>

On Wed, 23 Dec 2009, David Miller wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Wed, 23 Dec 2009 21:45:57 +0200 (EET)
> 
> > On Tue, 22 Dec 2009, David Miller wrote:
> > 
> >> From: Roel Kluin <roel.kluin@gmail.com>
> >> Date: Wed, 23 Dec 2009 03:00:24 +0100
> >> 
> >> > I could be confused, but in net/ipv4/tcp_output.c:217:
> >> > 
> >> >                 space = max_t(u32, sysctl_tcp_rmem[2], sysctl_rmem_max);
> >> >                 space = min_t(u32, space, *window_clamp);
> >> > ------------------------^^^^^
>  ...
> > 
> > I don't understand how window_clamp line could be changed to max_t.
> > ...I guess min in both would seem the most reasonable one?
> 
> Nope, the first one must be max.  Since I'm pretty sure we let the
> dynamic RX buffer resizing exceed sysctl_rmem_max if necessary.
> 
> And that's what is controlled by sysctl_tcp_rmem[2]

Yeah, I'm wrong, and besides misread your "It looks correct" to mean the 
proposed change rather than the current code.

-- 
 i.
---696230645-1345756015-1261603295=:10866--
