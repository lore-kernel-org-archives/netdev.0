From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP's initial cwnd setting correct?...
Date: Wed, 8 Aug 2007 16:05:09 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0708081558000.23600@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0708061508070.8788@kivilampi-30.cs.helsinki.fi>
 <20070807.220127.98862306.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1540810443-1186578309=:23600"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47573 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757541AbXHHNFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 09:05:11 -0400
In-Reply-To: <20070807.220127.98862306.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1540810443-1186578309=:23600
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 7 Aug 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 6 Aug 2007 15:37:15 +0300 (EEST)
> 
> > ...Another thing that makes me wonder, is the tp->mss_cache > 1460 check 
> > as based on rfc3390 (and also it's precursor rfc2414) with up to 2190 
> > bytes MSS TCP can use 3 as initial cwnd...
> 
> I did the research and my memory was at least partially right.
> 
> Below is an old bogus change of mine and the later revert with
> Alexey's explanation.
> 
> This seems to be dealing with receive window calculation issues,
> rather than snd_cwnd.  But they might be related and you should
> consider this very seriously.

...Thanks about the info, I'll study it carefully and see what's
relevant in here too. And anyway we're currently on the safer side
as the potential issues only make it more conservative than the RFC 
allows, so there's no hurry to get it in until the solution is
acceptable if there's indeed a need for a change.


-- 
 i.
---696243703-1540810443-1186578309=:23600--
