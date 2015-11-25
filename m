From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 06/16] i40e: Properly cast type for arithmetic
Date: Wed, 25 Nov 2015 02:46:51 -0800
Message-ID: <1448448411.3154.32.camel@intel.com>
References: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1448409886-90686-7-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1448412212.20113.12.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-tpPL7fd/pcnPXNsqk/39"
Cc: Helin Zhang <helin.zhang@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Joe Perches <joe@perches.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:16192 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750832AbbKYKrE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2015 05:47:04 -0500
In-Reply-To: <1448412212.20113.12.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-tpPL7fd/pcnPXNsqk/39
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-11-24 at 16:43 -0800, Joe Perches wrote:
> On Tue, 2015-11-24 at 16:04 -0800, Jeff Kirsher wrote:
> > From: Helin Zhang <helin.zhang@intel.com>
> >=20
> > Pointer of type void * shouldn't be used in arithmetic, which may
> > result in compilation error. Casting of (u8 *) can be added to fix
> > that.
> >=20
>=20
> void * arithmetic is used quite frequently in the kernel.
>=20
> What compiler emits an error?

When you use the gcc -Wpointer-arith, it generates the warning.
--=-tpPL7fd/pcnPXNsqk/39
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWVZGbAAoJEOVv75VaS+3OxSUP/01QOH71OvLAtLqlsXYS8EMe
RpejpyIAh7Rn4ZF2813+LGcGMiZkYbUgVjPCj3MKO+63V2dT0NsoTUfhEgwkr345
ovKrHZTxriD62mJHuoTVl4q4XY0fxojP4tqJIipEt3DlgQRjPll0JX/hjfEqDQr+
Z7+4L9iC4A0z842M0PKIZwEE0tEQZst7RKyEclkf3LaihBHJAG3yj5BNdLd1ycNT
xYN9sjpTxbhSIV3GYSiHdd/BjmXFtMhWpIbGSDzynLKiUyAE3MEYnNdcDMdFmR9/
iLS2slXclj6Ne6xSZ/IIOy5P2qRE0Xxr8T+gJxSC9fV/ftOabBdmmbFJ7HzbK/E+
a7Jc4YzM5OnTHT3p2rhOzK49MeEHZg5NVjbdEHKNFq7Y8xIWawzle/MHRZGJOdfa
VwTBu1jTlRxTXXPIFCTyJmP93br1+64mNDNmSMwmrseamVpP3+B4eti2BmSZsed5
yPl4xZj+BUSN9Ri7WnAFf/T59EnYdqQZmT6RqVO8N3ZgUGl3gsuNDIIQu1VnuXKi
iGsPVBZ7D/3ZzxTApPny+E9s3767s4lv6qZtZWhLcjFqhguciL9Q+OlvpGBz6vwy
cvnKnt7Dcjjh+jUCSW9K11+otm+rbHYEU6a92/7qa2syOKsQowtBnXqZ5EB3i8Ce
moUXr3qo6K6OA1NBPbMR
=xP/O
-----END PGP SIGNATURE-----

--=-tpPL7fd/pcnPXNsqk/39--
