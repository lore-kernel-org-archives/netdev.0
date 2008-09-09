From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH -mm] Fix dev_load() compilation again
Date: Tue, 09 Sep 2008 08:27:55 +0200
Message-ID: <1220941675.31304.93.camel@johannes.berg>
References: <20080904224004.d3dd3076.akpm@linux-foundation.org>
	 <20080905193244.GD11569@x200.localdomain> <48C18E8B.9050201@ct.jp.nec.com>
	 <20080908151707.21cd1c6c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-3MZwQMh/GmiqTKFD4EbJ"
Cc: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>, adobriyan@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	sfr@canb.auug.org.au, Rusty Russell <rusty@rustcorp.com.au>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:40906 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753454AbYIIG2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 02:28:10 -0400
In-Reply-To: <20080908151707.21cd1c6c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-3MZwQMh/GmiqTKFD4EbJ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,

On Mon, 2008-09-08 at 15:17 -0700, Andrew Morton wrote:
> On Fri, 05 Sep 2008 12:54:51 -0700
> Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com> wrote:

> > in -next tree, this patch fixes the compilation error instead of
> > my patch. So, there is a conflict.

I think I like this patch better than Stephen's, but despite causing the
problem I'm not sure what I can do at this point.

> Give that there's already a fix in linux-next, I can't do anything here.
>=20
> Rusty, the regression was introduced by
>=20
> commit 4cb9da6ecc2b0e25056b45981239475f8509d59d
> Author:     Johannes Berg <johannes@sipsolutions.net>
> AuthorDate: Wed Jul 9 10:28:42 2008 +0200
> Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
> CommitDate: Tue Aug 26 10:19:47 2008 +1000
>=20
>     remove CONFIG_KMOD from net

Rusty, can you take
http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.27-rc5/2=
.6.27-rc5-mm1/broken-out/net-fix-compilation-ng-when-config_module.patch

(although I'd rather see the blank line stay) and fold it into that
patch or put it into the tree that Stephen pulls?

johannes

--=-3MZwQMh/GmiqTKFD4EbJ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIxhdnAAoJEKVg1VMiehFYYwgP/2YAUFjHttLEf/3ZgOHfeAeh
L0xJynfz9CnIs4yC9S93PzlBudbOUt1YZdJ61wKwzaXegskd/PFsLqIoGFQWOwcE
qb2678+zREmL8cbSukTUFZ58CIxoLVqirlHxzff1rPcr6QFwcDS2EUwGNVA4Avd/
BU+9bNFW7OSEpoavQuREhhZ7ukeBktXk48v9JL3D2S2r7sEHlok0aC0yh/3fCTP0
ZtfomPP2TKyYPhw6UJm6/oziz9JGYIU/bupXL5GD0exq2CJ7ATrsBgBUnHuI6GwH
oPVnhsJvqjRDXJ5jC+Plt7BPA4OgTxq5i/k/WCc+sML88v06j99cQK1GFFrK7rT3
fikW8m6kPICSna1xIn40zz9ao5JFgXP7MAa/583o4Qu/edkDjciDaS4ZqcE/JnAS
Au0jBMCPhDAnaLhhHoj/GhQqVoIIekRUgLnC2q2WP3bt36q+SdAy3LPsxbcuzl7n
SsmYBdxq+/WFW7YlVNIxJi2Nfh4kMHtN1IdRdldVvkdetzzt1E0SBlg39vYq2SmH
tXFMo4YCtr46VmeBluUZwhRvKghQlW0CZ/iXu5nCRZToaGuL0st28Ed2gbc/Z2r4
KGS2wvTL7ViOnuQNGOYUDLL4Qc2XU0tGKuuBMAVn2956QnTBX6QsPyNhiARuxo35
WBsQ66w3+yTdZ5c0WJ5+
=gffD
-----END PGP SIGNATURE-----

--=-3MZwQMh/GmiqTKFD4EbJ--

