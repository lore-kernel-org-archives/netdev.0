From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bonding vs GSO vs checksumming.
Date: Tue, 28 Sep 2010 11:49:07 +0900
Message-ID: <20100928024907.GA24948@gondor.apana.org.au>
References: <AANLkTim2FF2n9JXfpdZmmnV5ZJ1ptC7se_JiU_z91okt@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux NetDev <netdev@vger.kernel.org>
To: Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:51093 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758002Ab0I1CtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 22:49:11 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTim2FF2n9JXfpdZmmnV5ZJ1ptC7se_JiU_z91okt@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 23, 2010 at 05:56:43PM -0700, Maciej =C5=BBenczykowski wrot=
e:
> I'm seeing the following:
>=20
> bonding: caps=3D(0x1113a3, 0x1113ab) len=3D18192 data_len=3D18120 ip_=
summed=3D0
>=20
> on a 2.6.34.5 based kernel originating from v6 tcp transmit (mtu 1280=
)
> on a bonded device of tg3 (presumably with TSO6) and forcedeth
> (presumably without TSO6).
>=20
> I can't quite figure out what this truly means...

Did it come with a kernel backtrace?

Thanks,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
