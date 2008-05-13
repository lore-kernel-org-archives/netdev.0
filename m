From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Fix FRTO+NewReno problem
Date: Tue, 13 May 2008 13:04:04 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805131258070.15369@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0805122143080.14152@wrl-59.cs.helsinki.fi>
 <20080512.154838.163999274.davem@davemloft.net>
 <Pine.LNX.4.64.0805130958001.14510@wrl-59.cs.helsinki.fi>
 <20080513.024915.161125347.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1818694060-1210673044=:15369"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58844 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbYEMKEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 06:04:06 -0400
In-Reply-To: <20080513.024915.161125347.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1818694060-1210673044=:15369
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 13 May 2008, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Tue, 13 May 2008 12:42:03 +0300 (EEST)
> 
> > On Mon, 12 May 2008, David Miller wrote:
> > 
> > > If I understand correctly, it is only non-SACK newreno case that can
> > > get the unnecessary retransmissions, right?  If so, it's not a big
> > > deal at all.
> > 
> > No, also SACK could get at least one quite easily if TCP has a small 
> > window, to get two of them with SACK one needs to have a stranger case
> > unless I missed something. If I just remove that forward transmission LOST 
> > marking avoidance unconditionally, it fixes that SACKFRTO window of 
> > failure too which was a pending thing to fix :-).
> 
> Ok.

Hmm, my paragraph was likely ambiguous. So unnecessary transmissions can 
occur with SACK with that change but another problem that would have 
required a fix went away with that change.

> > Btw, the first two fixes (workaround was not included) also fixed bugzilla 
> > #10063, I just got a confirmation about that as well.
> > 
> > I'll send the two patches still pending separately in a minute.
> 
> Thank you.

Forgot to mention earlier, these should go to stable too (but you 
probably figured that out anyway).

-- 
 i.
---696208474-1818694060-1210673044=:15369--
