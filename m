From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [patch net-next] cxgb3: update firmware version
Date: Tue, 14 Feb 2012 01:59:14 +0000
Message-ID: <1329184754.3048.33.camel@deadeye>
References: <20120213202846.631.30806.stgit@speedy5.asicdesigners.com>
	 <1329165817.2092.62.camel@shinybook.infradead.org>
	 <4F398303.1030606@chelsio.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-FfgOr2VYUq0CLg4M5W9K"
Cc: David Woodhouse <dwmw2@infradead.org>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>, nhorman@tuxdriver.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:48520 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751399Ab2BNB7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 20:59:20 -0500
In-Reply-To: <4F398303.1030606@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-FfgOr2VYUq0CLg4M5W9K
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-02-13 at 13:39 -0800, Divy Le Ray wrote:
> On Monday, February 13, 2012 12:43:37 PM, David Woodhouse wrote:
> >
> > On Mon, 2012-02-13 at 12:28 -0800, Divy Le Ray wrote:
> >>
> >> This patch updates the firmware version cxgb3 is requesting to 7.12.0.
> >
> >
> > I'm confused. Your patch doesn't change anything in the driver, except
> > the firmware version. So why is it a "major" change?
>=20
> Hi David,
>=20
> cxgb3 embeds the firmware file name it will request at load time.
> It uses the FW_VERSION_* defs to construct the firmware name FW_FNAME=20
> before calling request_firmware().
> Hence the need to update the firmware minor version.
>=20
> On the other hand, the driver version update is not a strict requirement=
=20
> here.
> I would prefer keeping it though.

The problems with this are:
1. Older kernel versions don't benefit from the firmware update.
2. The old firmware has to be kept in linux-firmware to support those
   old kernel versions, and distributions may have to package more
   versions.

To avoid this, the firmware filename should only be changed if you make
incompatible changes in the driver/firmware interface.

Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-FfgOr2VYUq0CLg4M5W9K
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATzm/8ue/yOyVhhEJAQoQ4xAAuHYB3waPJPC2G/UdXr+7bEeGB+hpVTRs
34laoEl6PMarS2SAmheb3sXNgMiiYW1YJ452C9lJ+HhbSmEWZJgHZz4g6GKziOlf
eQRrn98tbb65qhfK8UV1mShxSkgy1YJsS9CwIhHc6ETL52enForGLc4L+yKr19Ae
+AiSrldGrv33TcVCfIUca9hIxg9y3+mJ4wRJQHUY/oEtT3WwwfYtG3CdtJb1eJ67
8WI3b1z0yRrCQ7JfAy4AIoRBd4I1TVD869ltp+5ylsCB7Pmzkc2ouJkV26CrKdtm
REYFZNLJvoktXy+BjtZTaApxY9T3717HEgNVRex1TznX7pTcZGOAlrdRU2IPJymX
YBFX4NKyq/OTVklUyPu7JioMIL/sF4dDYcfJvwQrBp3HVxHZnApvZzom73Mi9zUj
iTU833o0Tw4Q91VjruK0tjJcXxv3RagaVvNmfnq+fP22SXmAla0zUKW+uDSL+naG
vY+WAF9WG7SMdUtVUgP9E8V0onA2wtHQWY6yWpF36gE+6UE4klNvzTToxQ/BkEH5
LMuZtl1h/CCCQX9pLYytmYxwv4IOLSMkOrWHzUtdspHRopkXfzodMpUK17wI4+BV
+P4ey3Mx/H2nLF2RPJSyuO4t9bod4G/ZQ2SnZBpi7UjsCMk92S5jyq5yfEMjSQI9
cHK16lCq+cQ=
=qgtQ
-----END PGP SIGNATURE-----

--=-FfgOr2VYUq0CLg4M5W9K--
