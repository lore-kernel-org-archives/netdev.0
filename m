From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v1 3/8] crypto:chcr- Fix key length for RFC4106
Date: Fri, 13 Jan 2017 00:42:55 +0800
Message-ID: <20170112164255.GF20085@gondor.apana.org.au>
References: <cover.1483599449.git.harsh@chelsio.com>
 <6d8e61299e051d51dacdb6bfd6c5e582b230027c.1483599449.git.harsh@chelsio.com>
 <20170112160959.GA19732@gondor.apana.org.au>
 <648404c5-4234-7895-d478-858433b0d093@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
        linux-crypto@vger.kernel.org
To: Harsh Jain <Harsh@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:46707 "EHLO
        helcar.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750819AbdALRA7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 12:00:59 -0500
Content-Disposition: inline
In-Reply-To: <648404c5-4234-7895-d478-858433b0d093@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2017 at 10:08:46PM +0530, Harsh Jain wrote:
>
> That case is already handled in next if condition.It will error out with -EINVAL in next condition.
> 
> if (keylen == AES_KEYSIZE_128) {

Good point.  Please split the patches according to whether they
should go into 4.10/4.11 and then resubmit.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
