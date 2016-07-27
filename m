From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: use printk instead of WARN for bad policy reporting
Date: Wed, 27 Jul 2016 14:31:27 +0800
Message-ID: <20160727063127.GA24473@gondor.apana.org.au>
References: <1469003555-30599-1-git-send-email-vegard.nossum@oracle.com>
 <578F6628.4010002@oracle.com>
 <20160727030117.GA23226@gondor.apana.org.au>
 <579852C9.1020505@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Vegard Nossum <vegard.nossum@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:41466 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858AbcG0Gbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 02:31:41 -0400
Content-Disposition: inline
In-Reply-To: <579852C9.1020505@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 27, 2016 at 08:20:57AM +0200, Vegard Nossum wrote:
>
> Here's another patch to remove that too.
> 
> I don't actually *use* this code myself and I feel the justification
> I've given for removing the WARN to be a bit weak, so if you don't take
> the patch I'll just keep it in my local tree to keep it from showing up
> again during fuzzing.

Please just kill the whole else clause.  For soft policy expires
we simply need to relay a message to the KM and nothing more.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
