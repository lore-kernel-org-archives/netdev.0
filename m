From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Using the aesni generic gcm(aes) aead in atomic context
Date: Tue, 31 Oct 2017 15:17:29 +0800
Message-ID: <20171031071729.GA25871@gondor.apana.org.au>
References: <AM4PR0501MB2723742986C5098642C50D01D4590@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031041015.GB24806@gondor.apana.org.au>
 <AM4PR0501MB27232A20751B0443EBA7B446D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "sd@queasysnail.net" <sd@queasysnail.net>,
        Boris Pismenny <borisp@mellanox.com>,
        "davejwatson@fb.com" <davejwatson@fb.com>
To: Ilya Lesokhin <ilyal@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orcrist.hmeau.com ([104.223.48.154]:51388 "EHLO
        deadmen.hmeau.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751564AbdJaHRz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 03:17:55 -0400
Content-Disposition: inline
In-Reply-To: <AM4PR0501MB27232A20751B0443EBA7B446D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 07:14:12AM +0000, Ilya Lesokhin wrote:
>
> However I'm still concerned about the lack of irq_fpu_usable() check.
> and I don't really want to do the check myself outside of the crypto code as it is
> arch specific.

Users of the crypto API shouldn't need to check irq_fpu_usable().
The crypto API should work regardless of what context you're in.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
