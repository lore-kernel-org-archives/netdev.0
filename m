From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH 1/2] Export firmware assigned labels of network devices
 to sysfs
Date: Tue, 01 Jun 2010 00:07:56 +1000
Message-ID: <1275314876.21246.29.camel@concordia>
References: <20100528115520.GA24114@littleblue.us.dell.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-yg7SOU5BEOdTQoE7Z/GI"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"Domsch, Matt" <Matt_Domsch@dell.com>,
	"Hargrave, Jordan" <Jordan_Hargrave@dell.com>,
	"Rose, Charles" <Charles_Rose@dell.com>,
	"Nijhawan, Vijay" <Vijay_Nijhawan@dell.com>
To: "K, Narendra" <Narendra_K@dell.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20100528115520.GA24114@littleblue.us.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-yg7SOU5BEOdTQoE7Z/GI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2010-05-28 at 06:55 -0500, K, Narendra wrote:
> Hello,
>=20
> This patch is in continuation of an earlier discussion -
>=20
> http://marc.info/?l=3Dlinux-netdev&m=3D126712978908314&w=3D3
>=20
> The patch has the following review suggestions from the community incorpo=
rated -
>=20
> 1. The name of the attribute has been changed from "smbiosname" to "label=
" to hide
> the implementation details.
> 2. The implementation has been moved to a new file drivers/pci/pci-label.=
c

You've changed the name, which is good, but the implementation is still
100% dependant on ACPI or DMI AFAICS.

So it seems to me until it's supported on another platform it may as
well go in pci-acpi.c, or at least only be compiled if (ACPI || DMI).
Otherwise it's just dead code.

cheers



--=-yg7SOU5BEOdTQoE7Z/GI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAkwDwrwACgkQdSjSd0sB4dLJIACcC4FH/RiVuZyPbrhGNCy5bmFU
YOQAoKIOIajhue1Csy0TwzRcrsWayR1V
=Z/vZ
-----END PGP SIGNATURE-----

--=-yg7SOU5BEOdTQoE7Z/GI--
