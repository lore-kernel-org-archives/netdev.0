From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Tue, 1 Dec 2009 22:27:01 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi>
References: <20091127223545.2a752429@houba> <alpine.DEB.2.00.0911272358030.11977@melkinpaasi.cs.helsinki.fi> <20091128010156.1219012a@houba> <alpine.DEB.2.00.0911281257270.25587@melkinpaasi.cs.helsinki.fi> <20091130195004.38dbc319@houba>
 <alpine.DEB.2.00.0911302113390.9826@melkinpaasi.cs.helsinki.fi> <20091130213727.2f4047d2@houba> <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi> <20091201211945.505d3c98@houba>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696230645-1831628680-1259699221=:1904"
Cc: Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33033 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957AbZLAU04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 15:26:56 -0500
In-Reply-To: <20091201211945.505d3c98@houba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-1831628680-1259699221=:1904
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Tue, 1 Dec 2009, Frederic Leroy wrote:

> Le Mon, 30 Nov 2009 23:37:56 +0200 (EET),
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> a écrit :
> 
> > On Mon, 30 Nov 2009, Frederic Leroy wrote:
> >
> > Could you try btw to disable frto (set tcp_frto sysctl to zero), in
> > theory it could cause zero cwnd if something else is wrong too (I
> > haven't yet read them all through so there might be other places
> > where a zero cwnd can be set). Also I'm interested what happens if
> > you disable timestamps, is the problem still reproducable.
> 
> I made 3 new traces and put it in the usual place.
> One with frto set to 0, one just after with frto set to 2.
> 
> And the last with timestamp disabled. 
> 
> All stream has stalled.

Thanks, I'll hopefully have some time tomorrow to go through all the new 
ones. In the meantime, can you provide your tso configuration on houba 
(ethtool -k dev). If tso is on it might be worth to try without it 
(set with -K), however, I don't expect it to change anything. Also,
I wonder if you have had some working (past) kernel version?

No need for additional traces atm, I'll get back to this once I've gone 
through the logs.

-- 
 i.
---696230645-1831628680-1259699221=:1904--
