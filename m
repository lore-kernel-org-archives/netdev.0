From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: RE: Using the aesni generic gcm(aes) aead in atomic context
Date: Tue, 31 Oct 2017 07:39:08 +0000
Message-ID: <AM4PR0501MB2723C23EAC7467B09587C2C9D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
References: <AM4PR0501MB2723742986C5098642C50D01D4590@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031041015.GB24806@gondor.apana.org.au>
 <AM4PR0501MB27232A20751B0443EBA7B446D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031071729.GA25871@gondor.apana.org.au>
 <AM4PR0501MB27231A649C20C10E024C83DBD45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031073239.GA25958@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "sd@queasysnail.net" <sd@queasysnail.net>,
        Boris Pismenny <borisp@mellanox.com>,
        "davejwatson@fb.com" <davejwatson@fb.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr00079.outbound.protection.outlook.com ([40.107.0.79]:17424
        "EHLO EUR02-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751658AbdJaHjL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 03:39:11 -0400
In-Reply-To: <20171031073239.GA25958@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, October 31, 2017 9:33 AM, Herbert Xu wrote:
> You are right.  generic-gcm-aesni is completely broken.
>=20
> It needs to be rewritten to use a wrapper as is done with rfc4106.

I think we should consider having a synchronous implementation that falls b=
ack
to integer implementation when the FPU is not available.
This would spare the users from having to handle the asynchronous case.

Hopefully the situation where the FPU is not available is rare enough=20
So it won't hurt the performance too much.
