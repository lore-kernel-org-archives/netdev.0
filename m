From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 1/3] drivers/staging/rtl8187se: Don't pass huge struct
 by value
Date: Mon, 15 Aug 2011 09:58:22 +1000
Message-ID: <20110815095822.7f7e32c5c8ba237b40cca863@canb.auug.org.au>
References: <alpine.LNX.2.00.1108130054220.7387@swampdragon.chaosbits.net>
	<20110813180531.34a47d9bf4851f8c1e9a227c@canb.auug.org.au>
	<alpine.LNX.2.00.1108142031330.14271@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__15_Aug_2011_09_58_22_+1000_IIj2HV4fgswkLVGa"
Cc: Greg Kroah-Hartman <gregkh@suse.de>, devel@driverdev.osuosl.org,
	linux-kernel@vger.kernel.org,
	Andrea Merello <andreamrl@tiscali.it>,
	Andre Nogueira <andre.neo.net@gmail.com>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Stefan Weil <weil@mail.berlios.de>,
	Ilia Mirkin <imirkin@alum.mit.edu>, netdev@vger.kernel.org
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:55832 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751272Ab1HNX6h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Aug 2011 19:58:37 -0400
In-Reply-To: <alpine.LNX.2.00.1108142031330.14271@swampdragon.chaosbits.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Mon__15_Aug_2011_09_58_22_+1000_IIj2HV4fgswkLVGa
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jesper,

On Sun, 14 Aug 2011 20:32:49 +0200 (CEST) Jesper Juhl <jj@chaosbits.net> wr=
ote:
>
> the "static inline" and defined in the header bits I didn't do because I=
=20
> was afraid that that was not valid in combination with EXPORT_SYMBOL().

You don't need to/cannot EXPORT_SYMBOL() static inlines in header files.
Any use in modules will pick up the static inline definition from the
header file when they are built.  Unless, of course, someone takes the
addresses of these functions, then you should not inline them.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__15_Aug_2011_09_58_22_+1000_IIj2HV4fgswkLVGa
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOSGEeAAoJEDMEi1NhKgbsklEH/1D32CK1/+NkLmqjBsMhqPF7
ieGmEnPRlVZs3K21bF/E2iU922J2ZKg/vMMMx/KnzqPy44UV4KfybUvCYaa/s75U
7Kk9UKtG9/vgY7mzW+se2BdNSQCnTCQSFxDv3CAWwPssaUstinS9+f24CVXfnqyV
1oNb5lY2ZbIeTIOeTUO2m631IQZpdqWc6d1r4n+RSUHSkEOuZ+TbF5ke4B0EtoF3
cD1X3Q3hIXET7EQFlbih25UlXbgi8d767+ux2x2nHNMq9Qtwhr3/570n2/VvAZVF
CmlgrFg8HJNrEe2zHXHSP9X5Yxrp7lZkPGCxrmWDB0rWP3xaJztl72F1+9PJsrs=
=IvWb
-----END PGP SIGNATURE-----

--Signature=_Mon__15_Aug_2011_09_58_22_+1000_IIj2HV4fgswkLVGa--
