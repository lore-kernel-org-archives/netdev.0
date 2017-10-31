From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: RE: Using the aesni generic gcm(aes) aead in atomic context
Date: Tue, 31 Oct 2017 07:23:35 +0000
Message-ID: <AM4PR0501MB27231A649C20C10E024C83DBD45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
References: <AM4PR0501MB2723742986C5098642C50D01D4590@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031041015.GB24806@gondor.apana.org.au>
 <AM4PR0501MB27232A20751B0443EBA7B446D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031071729.GA25871@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "sd@queasysnail.net" <sd@queasysnail.net>,
        Boris Pismenny <borisp@mellanox.com>,
        "davejwatson@fb.com" <davejwatson@fb.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0074.outbound.protection.outlook.com ([104.47.2.74]:2688
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751658AbdJaHXh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 03:23:37 -0400
In-Reply-To: <20171031071729.GA25871@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, October 31, 2017 9:17 AM, Herbert Xu wrote:
>=20
> Users of the crypto API shouldn't need to check irq_fpu_usable().
> The crypto API should work regardless of what context you're in.
>=20

I agree, I'm just saying that as far as I can tell that's not true
for the aesni generic gcm(aes) aead.
It just assume the FPU is available without checking.
