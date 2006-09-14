From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH]:[XFRM] BEET mode
Date: Thu, 14 Sep 2006 08:39:59 -0700
Message-ID: <20060914083959.60538a79.rdunlap@xenotime.net>
References: <1158164779.4508312bab9c2@webmail.hiit.fi>
	<20060913201423.06990b98.rdunlap@xenotime.net>
	<Pine.SOL.4.64.0609141316420.361@kekkonen.cs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Diego Beltrami <Diego.Beltrami@hiit.fi>, netdev@vger.kernel.org,
	davem@davemloft.net, Herbert Xu <herbert@gondor.apana.org.au>,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:22422 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1750841AbWINPis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 11:38:48 -0400
Received: from midway.site ([71.117.233.155]) by xenotime.net for <netdev@vger.kernel.org>; Thu, 14 Sep 2006 08:38:47 -0700
To: Miika Komu <miika@iki.fi>
In-Reply-To: <Pine.SOL.4.64.0609141316420.361@kekkonen.cs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Sep 2006 13:25:49 +0300 (EEST) Miika Komu wrote:

> Below is a fixed version of the announced patch. I hope this one is ok.

Yes, the split line is fixed now.

I suppose that this applies to Dave's netdev git tree?
That would explain why I get lots of patch errors when I try
to apply it to 2.6.18-rc7...
or it could be that the surrounding patch context lines
have too many leading spaces for some reason.  That's what
it looks like to me.
Did you take the patch from the mailing list and try to
apply it to your unpatched tree?

linux-2618-rc7work> dryrun < ~/beet-mode.patch 
1 out of 1 hunk FAILED -- saving rejects to file include/linux/in.h.rej
2 out of 2 hunks FAILED -- saving rejects to file include/linux/ip.h.rej
1 out of 1 hunk FAILED -- saving rejects to file include/linux/ipsec.h.rej
1 out of 1 hunk FAILED -- saving rejects to file include/linux/xfrm.h.rej
1 out of 1 hunk FAILED -- saving rejects to file net/ipv4/Kconfig.rej
1 out of 1 hunk FAILED -- saving rejects to file net/ipv4/Makefile.rej
2 out of 2 hunks FAILED -- saving rejects to file net/ipv4/esp4.c.rej
2 out of 2 hunks FAILED -- saving rejects to file net/ipv4/ipcomp.c.rej
1 out of 1 hunk FAILED -- saving rejects to file net/ipv6/Kconfig.rej
1 out of 1 hunk FAILED -- saving rejects to file net/ipv6/Makefile.rej
2 out of 2 hunks FAILED -- saving rejects to file net/ipv6/ipcomp6.c.rej
1 out of 1 hunk FAILED -- saving rejects to file net/xfrm/xfrm_user.c.rej

---
~Randy
