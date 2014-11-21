From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] ixgbe: make VLAN filter conditional in SR-IOV case
Date: Fri, 21 Nov 2014 01:28:19 +0000
Message-ID: <1416533299.7215.17.camel@decadent.org.uk>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05D9D336@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-7axfqq2RjRK3lAtmm77X"
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05D9D336@BPXM14GP.gisp.nec.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-7axfqq2RjRK3lAtmm77X
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-11-13 at 08:28 +0000, Hiroshi Shimamoto wrote:
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>=20
> Disable hardware VLAN filtering if netdev->features VLAN flag is dropped.
>=20
> In SR-IOV case, there is a use case which needs to disable VLAN filter.
> For example, we need to make a network function with VF in virtualized
> environment. That network function may be a software switch, a router
> or etc. It means that that network function will be an end point which
> terminates many VLANs.
>=20
> In the current implementation, VLAN filtering always be turned on and
> VF can receive only 63 VLANs. It means that only 63 VLANs can be used
> and it's not enough at all for building a virtual router.
>=20
> With this patch, if the user turns VLAN filtering off on the host, VF
> can receive every VLAN packet.
> The behavior is changed only if VLAN filtering is turned off by ethtool.
[...]

What happens when VLAN filtering is turned back on and a VF uses too
many VLANs?  It seems like that should either be prevented (you can't
turn it back on) or the driver should log a message saying the VF is now
broken.

Ben.

--=20
Ben Hutchings
Beware of bugs in the above code;
I have only proved it correct, not tried it. - Donald Knuth

--=-7axfqq2RjRK3lAtmm77X
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVG6VPee/yOyVhhEJAQoqBhAAmpUy80xu2SpV/gjvI8y9zpTefOgUPUgG
MVRTUEoJVaQfeKZvN1tzrLxz7OXukAQ/ZWjvktZghjW/hj+aMqJ+nE/NkzDLszU2
117RHcnF6oy1Ts8+Dkbf2dDLpfZSJ3x5LByLrZ/Tnh9FduNp/AVdChJCDOBy4Ku9
2t54hO6wZzx/u+HEVlueHrtxtLZv9d83bSUYKSkl7ZdmCUOEiyc6M5weWWPtjbQV
YhXEHjnq/F+wRSWx54Fw7FBEMENeTe1K8snfHazLAjm2yENGbRG7vzLjAAqy096a
GSXtKJQNv0yhbwe52NRV3O9gb+6u/JsDsnlbVb1YuqwVIjBGlvHA25oNVqHqbXZF
weXj8om847lw7e4S3LyLFwLCbJNfYZIIDdhMqOTcucYgjshA93ezCcB2CndB7EUa
vHN7D7KH8X+gfBKxknSLK+92OMSfoWUtmQ8eG2ydQjtmF8/k360RhKTKUrwm97mD
MI5jFsNTF8FjH+KSTDQoxndaR2Uq8gsQBgkQJj28kP9stTrXQyGRS5LMYwDDJK5c
5GUcoMB1jctjypE4f/Fg4dsnhtg7rSeZU2HnaVTIZ1sxkcprSki1toDzYf99h1SC
S/6KbSKvTlz7E8IuNlMla1Mdr38mkWou2KUt+hGLMPS8fgzzir5G9jm+c0TDIxbb
l+2/MgtHHw8=
=y4ZZ
-----END PGP SIGNATURE-----

--=-7axfqq2RjRK3lAtmm77X--
