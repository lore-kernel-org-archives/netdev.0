From: Michael Ellerman <michael@ellerman.id.au>
Subject: RE: [PATCH 1/2] Export firmware assigned labels of network devices
 to sysfs
Date: Thu, 03 Jun 2010 09:54:44 +1000
Message-ID: <1275522884.17895.8.camel@concordia>
References: <20100528115520.GA24114@littleblue.us.dell.com>
	 <1275314876.21246.29.camel@concordia>
	 <EDA0A4495861324DA2618B4C45DCB3EE612864@blrx3m08.blr.amer.dell.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-MyEyo0KaYUiHYSlJRRer"
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, Matt_Domsch@Dell.com,
	Jordan_Hargrave@Dell.com, Charles_Rose@Dell.com,
	Vijay_Nijhawan@Dell.com
To: Narendra_K@Dell.com
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <EDA0A4495861324DA2618B4C45DCB3EE612864@blrx3m08.blr.amer.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-MyEyo0KaYUiHYSlJRRer
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2010-06-01 at 00:12 +0530, Narendra_K@Dell.com wrote:
> > On Fri, 2010-05-28 at 06:55 -0500, K, Narendra wrote:
> > > Hello,
> > >
> > > This patch is in continuation of an earlier discussion -
> > >
> > > http://marc.info/?l=3Dlinux-netdev&m=3D126712978908314&w=3D3
> > >
> > > The patch has the following review suggestions from the community
> > > incorporated -
> > >
> > > 1. The name of the attribute has been changed from "smbiosname" to
> > > "label" to hide the implementation details.
> > > 2. The implementation has been moved to a new file
> > > drivers/pci/pci-label.c
> >=20
> > You've changed the name, which is good, but the implementation is still
> > 100% dependant on ACPI or DMI AFAICS.
> >=20
> > So it seems to me until it's supported on another platform it may as
> > well go in pci-acpi.c,=20
>=20
> You mean the ACPI _DSM ? If yes, it is expected to become a standard
> very soon. I assume you meant non-Dell platforms by another platform.

No. I mean non-x86 platforms, yes they still exist.

cheers

--=-MyEyo0KaYUiHYSlJRRer
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAkwG70EACgkQdSjSd0sB4dIkjACgxnKDonndNDqvSc7OIROZVY5V
W7EAn1Ys4rmttJDv6ruSQ7WVp0Q82Rbe
=sCsc
-----END PGP SIGNATURE-----

--=-MyEyo0KaYUiHYSlJRRer--

