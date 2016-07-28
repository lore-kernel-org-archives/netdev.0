From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: use printk instead of WARN for bad policy reporting
Date: Thu, 28 Jul 2016 06:58:46 +0200
Message-ID: <20160728045846.GI5710@gauss.secunet.com>
References: <1469003555-30599-1-git-send-email-vegard.nossum@oracle.com>
 <578F6628.4010002@oracle.com>
 <20160727030117.GA23226@gondor.apana.org.au>
 <579852C9.1020505@oracle.com>
 <20160727063127.GA24473@gondor.apana.org.au>
 <5798583F.6060404@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <stephen@networkplumber.org>,
	<netdev@vger.kernel.org>
To: Vegard Nossum <vegard.nossum@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:33787 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754484AbcG1E6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jul 2016 00:58:49 -0400
Content-Disposition: inline
In-Reply-To: <5798583F.6060404@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 27, 2016 at 08:44:15AM +0200, Vegard Nossum wrote:
> On 07/27/2016 08:31 AM, Herbert Xu wrote:
> >On Wed, Jul 27, 2016 at 08:20:57AM +0200, Vegard Nossum wrote:
> >>
> >>Here's another patch to remove that too.
> >>
> >>I don't actually *use* this code myself and I feel the justification
> >>I've given for removing the WARN to be a bit weak, so if you don't take
> >>the patch I'll just keep it in my local tree to keep it from showing up
> >>again during fuzzing.
> >
> >Please just kill the whole else clause.  For soft policy expires
> >we simply need to relay a message to the KM and nothing more.
> 
> Try #2 :-)
> 
> 
> Vegard

> >From e5111e4dcd0e0c0990d3f4bba0ba0bc9d0b40bae Mon Sep 17 00:00:00 2001
> From: Vegard Nossum <vegard.nossum@oracle.com>
> Date: Wed, 27 Jul 2016 08:13:14 +0200
> Subject: [PATCH] xfrm: get rid of another incorrect WARN
> 
> During fuzzing I regularly run into this WARN(). According to Herbert Xu,
> this "certainly shouldn't be a WARN, it probably shouldn't print anything
> either".
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>

Also applied to the ipsec tree, thanks a lot!
