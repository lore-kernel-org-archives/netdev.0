From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v1 0/8] crypto:chcr- Bug fixes
Date: Fri, 13 Jan 2017 00:14:34 +0800
Message-ID: <20170112161434.GB19732@gondor.apana.org.au>
References: <cover.1483599449.git.harsh@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
        linux-crypto@vger.kernel.org
To: Harsh Jain <harsh@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:59677 "EHLO
        helcar.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750852AbdALQOn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 11:14:43 -0500
Content-Disposition: inline
In-Reply-To: <cover.1483599449.git.harsh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 06, 2017 at 02:01:31PM +0530, Harsh Jain wrote:
> The patch series is based on Herbert's cryptodev-2.6 tree.
> It include bug fixes.
> 
> Atul Gupta (4):
>   crypto:chcr-Change flow IDs
>   crypto:chcr- Fix panic on dma_unmap_sg
>   crypto:chcr- Check device is allocated before use
>   crypto:chcr- Fix wrong typecasting
> Harsh Jain (4):
>   crypto:chcr- Fix key length for RFC4106
>   crypto:chcr- Use cipher instead of Block Cipher in gcm setkey
>   crypto:chcr: Change cra_flags for cipher algos
>   crypto:chcr- Change algo priority

When you resubmit this please split it into two series.  Please
send the critical bug fixes (panic + key length + alloc check)
in one series separate from the others.  This way I can push
them easily to the 4.10 tree.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
