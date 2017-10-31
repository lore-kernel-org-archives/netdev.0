From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Using the aesni generic gcm(aes) aead in atomic context
Date: Tue, 31 Oct 2017 15:44:38 +0800
Message-ID: <20171031074438.GA26042@gondor.apana.org.au>
References: <AM4PR0501MB2723742986C5098642C50D01D4590@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031041015.GB24806@gondor.apana.org.au>
 <AM4PR0501MB27232A20751B0443EBA7B446D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031071729.GA25871@gondor.apana.org.au>
 <AM4PR0501MB27231A649C20C10E024C83DBD45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031073239.GA25958@gondor.apana.org.au>
 <AM4PR0501MB2723C23EAC7467B09587C2C9D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "sd@queasysnail.net" <sd@queasysnail.net>,
        Boris Pismenny <borisp@mellanox.com>,
        "davejwatson@fb.com" <davejwatson@fb.com>
To: Ilya Lesokhin <ilyal@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orcrist.hmeau.com ([104.223.48.154]:51418 "EHLO
        deadmen.hmeau.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751658AbdJaHpF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 03:45:05 -0400
Content-Disposition: inline
In-Reply-To: <AM4PR0501MB2723C23EAC7467B09587C2C9D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 07:39:08AM +0000, Ilya Lesokhin wrote:
> 
> I think we should consider having a synchronous implementation that falls back
> to integer implementation when the FPU is not available.
> This would spare the users from having to handle the asynchronous case.
> 
> Hopefully the situation where the FPU is not available is rare enough 
> So it won't hurt the performance too much.

For your intended use case I think async processing should work just
fine as it does for IPsec.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
