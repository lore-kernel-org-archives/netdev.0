From: Felipe Balbi <balbi@ti.com>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: Add support for new
 CPSW IP version
Date: Wed, 31 Jul 2013 23:26:17 +0300
Message-ID: <20130731202617.GB3737@radagast>
References: <20130731144957.GC4904@netboy>
 <20130731152827.GB25618@radagast>
 <20130731163845.GB4234@netboy>
 <20130731184525.GA629@radagast>
 <20130731192229.GB8027@netboy>
 <20130731194332.GA900@radagast>
 <20130731194523.GB900@radagast>
 <20130731200428.GD8027@netboy>
 <20130731200756.GA3737@radagast>
 <20130731202006.GE8027@netboy>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vGgW1X5XWziG23Ko"
Cc: Felipe Balbi <balbi@ti.com>, Mugunthan V N <mugunthanvnm@ti.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-omap@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:47310 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757309Ab3GaU0f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 16:26:35 -0400
Content-Disposition: inline
In-Reply-To: <20130731202006.GE8027@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--vGgW1X5XWziG23Ko
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Wed, Jul 31, 2013 at 10:20:07PM +0200, Richard Cochran wrote:
> On Wed, Jul 31, 2013 at 11:07:56PM +0300, Felipe Balbi wrote:
> >=20
> > what I'm saying is that we can give new IP revision a chance to work if
> > they have no programming model differences (except for, perhaps, new
> > features and different erratas).
>=20
> But it also has a chance to fail when there are differences.
> Comparing CPSW V1 with V2, it appears that TI likes to move the
> registers around between versions. To me, this is reason enough to
> make the driver defensive.

oh well, we can go on and on with this. Unfortunately we (SW team) don't
have control over the HW folks. We strongly suggest that they don't
break SW compatibility, and that's starting to become true.

You can very well expect next version of CPSW to be SW compatible. If it
isn't, then TI will send patches to add a new revision check and treat
it well. We are the first ones to have access to new versions of all
our IPs anyway.

And, IMHO, even if HW engineers decides to move registers around in CPSW
v3, that still doesn't chage the fact that defaulting to highest known
revision is a good practice.

Bailing out just because the revision check isn't what you expect it to
be is a very poor practice and leads to periodic patches updating
'switch' statements all over the place.

--=20
balbi

--vGgW1X5XWziG23Ko
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJR+XLpAAoJEIaOsuA1yqREyZoQAK3VNCGpmQC9iDx5NAn+az3a
JapntkM8HLZeMZZgjWP74fazKyqy01DUcT1dja6aVvoHNGFuOeUtisvR4ke9o/R0
97PJEliZpODdfMEX10C5NxRlEQfjflmdL6pSjFvIldB6AlBjV9Ng+MgVH35WqnMf
/96WkIvSg8gyNZY6czEx900gPVZ8yE1dSI4WTFQ3pvLMe+ruhijRJSZyDFgetrvc
elG/qOChw+e3Rbvsw3HtGQGJpA0k3UcH5UDqdwLv3IsrKhAB2qPY4U1PlAWdkCxo
A13xB4WhrXCFgnhMrCbhdQaXgdCdeCrKBCk4+VQ9Y0FmC0RRXg/3tSUVqk4BT6V1
s+mt2SjuGOlB1IOeopI+RdYVLmzeLsxdF19YdVuLvWMawsJAVzstq+P0rjv62HQX
CtSMzF4DssIIiMhN23Lp7NUjbcfcniVzwUArJERnAIKtdjHAMErQXZWJPIS1KXRc
fMNcU2EQ2EQM4Hlc2KYEGlMd6TdC6Bm2EyD0ubuRQNf8oT4LvBAre1qjLkiClzo1
xkhhK12E0e0sWxp0A4clr9sBd8DsV1PgaqneHUKxuPzQJvHXj//budJXJMzCGDK2
fflOORs9VWY6rWiKykJ8Nww+kjMYA+M7DbYM0WAVTzHE7+UvZ+uFpkLOsgDklVbM
sPgmpdgYEFaoPdldGuHF
=oeHk
-----END PGP SIGNATURE-----

--vGgW1X5XWziG23Ko--
