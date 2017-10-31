From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Using the aesni generic gcm(aes) aead in atomic context
Date: Tue, 31 Oct 2017 15:32:39 +0800
Message-ID: <20171031073239.GA25958@gondor.apana.org.au>
References: <AM4PR0501MB2723742986C5098642C50D01D4590@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031041015.GB24806@gondor.apana.org.au>
 <AM4PR0501MB27232A20751B0443EBA7B446D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031071729.GA25871@gondor.apana.org.au>
 <AM4PR0501MB27231A649C20C10E024C83DBD45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "sd@queasysnail.net" <sd@queasysnail.net>,
        Boris Pismenny <borisp@mellanox.com>,
        "davejwatson@fb.com" <davejwatson@fb.com>
To: Ilya Lesokhin <ilyal@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orcrist.hmeau.com ([104.223.48.154]:51402 "EHLO
        deadmen.hmeau.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751849AbdJaHdH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 03:33:07 -0400
Content-Disposition: inline
In-Reply-To: <AM4PR0501MB27231A649C20C10E024C83DBD45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 07:23:35AM +0000, Ilya Lesokhin wrote:
> On Tuesday, October 31, 2017 9:17 AM, Herbert Xu wrote:
> > 
> > Users of the crypto API shouldn't need to check irq_fpu_usable().
> > The crypto API should work regardless of what context you're in.
> 
> I agree, I'm just saying that as far as I can tell that's not true
> for the aesni generic gcm(aes) aead.
> It just assume the FPU is available without checking.

You are right.  generic-gcm-aesni is completely broken.

It needs to be rewritten to use a wrapper as is done with rfc4106.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
