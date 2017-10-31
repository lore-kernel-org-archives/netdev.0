From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: RE: Using the aesni generic gcm(aes) aead in atomic context
Date: Tue, 31 Oct 2017 07:58:24 +0000
Message-ID: <AM4PR0501MB272335B562F95A02453F2E34D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
References: <AM4PR0501MB2723742986C5098642C50D01D4590@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031041015.GB24806@gondor.apana.org.au>
 <AM4PR0501MB27232A20751B0443EBA7B446D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031071729.GA25871@gondor.apana.org.au>
 <AM4PR0501MB27231A649C20C10E024C83DBD45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031073239.GA25958@gondor.apana.org.au>
 <AM4PR0501MB2723C23EAC7467B09587C2C9D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031074438.GA26042@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "sd@queasysnail.net" <sd@queasysnail.net>,
        Boris Pismenny <borisp@mellanox.com>,
        "davejwatson@fb.com" <davejwatson@fb.com>,
        Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr50053.outbound.protection.outlook.com ([40.107.5.53]:56192
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750872AbdJaH6b (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 03:58:31 -0400
In-Reply-To: <20171031074438.GA26042@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, October 31, 2017 9:45 AM, Herbert Xu wrote:
>=20
> For your intended use case I think async processing should work just fine=
 as it
> does for IPsec.
>=20

I haven't dived into the async IPSEC fallback code yet, but it seems compli=
cated.
I'm not sure it make the correct performance/complexity tradeoff.
