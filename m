From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: use printk instead of WARN for bad policy reporting
Date: Wed, 27 Jul 2016 11:01:18 +0800
Message-ID: <20160727030117.GA23226@gondor.apana.org.au>
References: <1469003555-30599-1-git-send-email-vegard.nossum@oracle.com>
 <578F6628.4010002@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Vegard Nossum <vegard.nossum@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:47056 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857AbcG0DB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 23:01:29 -0400
Content-Disposition: inline
In-Reply-To: <578F6628.4010002@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2016 at 01:53:12PM +0200, Vegard Nossum wrote:
> On 07/20/2016 10:32 AM, Vegard Nossum wrote:
> >AFAICT this message is just printed whenever input validation fails.
> >This is a normal failure and we shouldn't be dumping the stack over it.
> >
> >Looks like it was originally a printk that was maybe incorrectly
> >upgraded to a WARN:
> >
> >commit 62db5cfd70b1ef53aa21f144a806fe3b78c84fab
> >Author: stephen hemminger <shemminger@vyatta.com>
> >Date:   Wed May 12 06:37:06 2010 +0000
> >
> >     xfrm: add severity to printk
> 
> Just FYI I'm also running into the
> 
> // reset the timers here?
> WARN(1, "Don't know what to do with soft policy expire\n");
> 
> in xfrm_add_pol_expire() from the same commit, but that looks
> potentially somewhat more serious (or at least it looks like we might
> want to do some sort of cleaning up), so I won't touch it for now.

It certainly shouldn't be a WARN, it probably shouldn't print
anything either.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
