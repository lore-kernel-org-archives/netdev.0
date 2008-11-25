From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 05/10] tcp: make tcp_sacktag_one able to handle partial
 skb too
Date: Tue, 25 Nov 2008 15:44:05 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811251538020.31282@wrl-59.cs.helsinki.fi>
References: <1227536527-29713-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20081124.211524.133482462.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-840998227-1227620645=:31282"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50178 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbYKYNoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 08:44:08 -0500
In-Reply-To: <20081124.211524.133482462.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-840998227-1227620645=:31282
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 24 Nov 2008, David Miller wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 24 Nov 2008 16:22:02 +0200
> 
> > This is preparatory work for SACK combiner patch which may
> > have to count TCP state changes for only a part of the skb
> > because it will intentionally avoids splitting skb to SACKed
> > and not sacked parts.
> > 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> Applied.
> 
> Although we need desperately to simplify this function at
> some point.  Anything past 6 arguments and you're going onto
> the stack on just about every cpu.

Sure, I made a note about that in the combine change which makes things 
much worse yet :-), which you obviously didn't read... ;-) I certainly 
was going to do that but didn't seem so useful to waste too much time 
early on it until I had a well working solution to the actual problem :-).

-- 
 i.
---696208474-840998227-1227620645=:31282--
