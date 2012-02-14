From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [patch net-next] cxgb3: update firmware version
Date: Tue, 14 Feb 2012 05:08:36 +0000
Message-ID: <1329196116.3048.66.camel@deadeye>
References: <20120213202846.631.30806.stgit@speedy5.asicdesigners.com>
	 <1329165817.2092.62.camel@shinybook.infradead.org>
	 <4F398303.1030606@chelsio.com> <1329184754.3048.33.camel@deadeye>
	 <4F39E7C9.20901@chelsio.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-o8dUtXgdbcJ2K7I9fOCr"
Cc: David Woodhouse <dwmw2@infradead.org>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>, nhorman@tuxdriver.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49758 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750744Ab2BNFIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 00:08:40 -0500
In-Reply-To: <4F39E7C9.20901@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-o8dUtXgdbcJ2K7I9fOCr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-02-13 at 20:49 -0800, Divy Le Ray wrote:
> On Monday, February 13, 2012 5:59:14 PM, Ben Hutchings wrote:
> >
> > On Mon, 2012-02-13 at 13:39 -0800, Divy Le Ray wrote:
> >>
> >> On Monday, February 13, 2012 12:43:37 PM, David Woodhouse wrote:
> >>>
> >>>
> >>> On Mon, 2012-02-13 at 12:28 -0800, Divy Le Ray wrote:
> >>>>
> >>>>
> >>>> This patch updates the firmware version cxgb3 is requesting to 7.12.=
0.
> >>>
> >>>
> >>>
> >>> I'm confused. Your patch doesn't change anything in the driver, excep=
t
> >>> the firmware version. So why is it a "major" change?
> >>
> >>
> >> Hi David,
> >>
> >> cxgb3 embeds the firmware file name it will request at load time.
> >> It uses the FW_VERSION_* defs to construct the firmware name FW_FNAME
> >> before calling request_firmware().
> >> Hence the need to update the firmware minor version.
> >>
> >> On the other hand, the driver version update is not a strict requireme=
nt
> >> here.
> >> I would prefer keeping it though.
> >
> >
> > The problems with this are:
> > 1. Older kernel versions don't benefit from the firmware update.
> > 2. The old firmware has to be kept in linux-firmware to support those
> > old kernel versions, and distributions may have to package more
> > versions.
> >
> > To avoid this, the firmware filename should only be changed if you make
> > incompatible changes in the driver/firmware interface.
>=20
> Hi Ben,
>=20
> The scheme for cxgb3 firmware update was designed in coordination with=
=20
> OEMs in the early stages of the driver existence back in 2007.

I'm aware that some OEMs have specifications for flash firmware updates
and version numbers.  I don't recall seeing anything about naming
firmware files that are loaded by the driver at boot.

In any case, whatever your OEMs want in out-of-tree driver packages is
not necessarily relevant to mainline Linux.

> Committing FW 7.12.0 under the name of t3fw-7.10.0.bin would be=20
> confusing, in my mind.

Indeed it would, but I was speaking in general terms - that it would be
preferable to use something like t3fw-<major>.bin.

I assume that the firmware blob has a version embedded in it, so that
the driver would still be able to report the exact version through
ethtool_ops::get_drvinfo.

> Some distributions have explicitly requested the FW rev number to be=20
> appended to the firmware file name.

Did they really want the full version there or did they want you to
distinguish incompatible versions?  Did they assume that the file would
be installed by a package (so that the package carries a version number)
or not?

Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-o8dUtXgdbcJ2K7I9fOCr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATznsVOe/yOyVhhEJAQqUDg//W3vYY+91SCM0xDD+7vUNmtnwRpTk+giL
zRt3GJoDtfFEfJ+s0YysfFVPDnDvcQcuKS276Z1IEvEZboMn/HdsWeR2bo6L9pK9
B7bUFLKmGpQqRZTf24+ukLfWQMmTy1d/Vv6EedfTExYNYmL1SU/b71R4bzSTY/d9
g5A1tQcciYJDXs6Zb2RbRnzaJJcsCw0GeV5zYjLarqLb3ofPsxt2iX09yu2uuJea
YkNzWc+bI7mN4tDdVuqUu6yxHrs+N8NRMViOsigCGGlXrUGeOSqWDwM3ZiXbyLww
dV5miczlIheSDd2fyO3Amqxe3uS1w6BIFgZjLoYlfWUGneZ0wYQ7BEFSyisqMQYV
vhiCtMpSP9Q9hW0jnHIIcfQ6ZVyvFFdLl3ViIYz9yXDXSsic+th93BYKGSNqccfY
5glApn8v7zVFO3jnVG+iGEEMoigcN8gEI7kRfJefSB0vnVGlOF7f0q9vm6D/rbxa
BjMsUvuq15JV3O9T//asbU833yHnrblbHYm2ElJm2Z5B6TdgoG9BrtKsb2iT0LO9
nrj59Io5VB4ng0rckBWB3429WxSZriHHgOn48Em5FMPovVeSer4MqBQEx9ztRx+y
VxHTT836Q2IYLEEJeYxIP9NBqQ75W6BwJ958/FqQW1QXNyc5SujL1Ulzok3YhNdp
slsWYsRnEN0=
=sAYl
-----END PGP SIGNATURE-----

--=-o8dUtXgdbcJ2K7I9fOCr--
