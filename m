From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [E1000-devel] [PATCH] ixgbe: make VLAN filter conditional in
 SR-IOV case
Date: Thu, 13 Nov 2014 09:08:32 -0800
Message-ID: <1415898512.2454.26.camel@jtkirshe-mobl>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05D9D336@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ztw/TBEd1Vw4sQECYlTr"
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05D9D336@BPXM14GP.gisp.nec.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ztw/TBEd1Vw4sQECYlTr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-11-13 at 08:28 +0000, Hiroshi Shimamoto wrote:
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>=20
> Disable hardware VLAN filtering if netdev->features VLAN flag is
> dropped.
>=20
> In SR-IOV case, there is a use case which needs to disable VLAN
> filter.
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
> The behavior is changed only if VLAN filtering is turned off by
> ethtool.
>=20
> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 10 ++++++++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |  4 ++++
>  2 files changed, 14 insertions(+)

Thanks Hiroshi, I will add your patch to my queue.

--=-ztw/TBEd1Vw4sQECYlTr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUZOWQAAoJEOVv75VaS+3O3uMP/1a2Lb2lIVsEZL0O8SstPVkf
yBFd0Dr8kBIqy+fvnuZEO3BAhrXK7dxkL56PXTOQ+bbt+ObSzJFPSi82F/FpDmT0
Zwnjq2nluRLugTdwd73OL96YL7NB5iBZe8SviSXCiiRnAjFHuXJz3NLEEYn/Vvwx
trlTRnu/JSmttRLBxXXwHy/2GlOHaFtGKQ3vc0JYW5fooTsgWn7pe7/SIQ8EeWK7
S8FvMFsEOylF+HELrXc6vqjWFOl42j+rsP+adFNS6c8YyIsq4OIwzCWec1By9CT0
oMpaH0b4d5KHhjagd964a9YHvzf3g64sLvBSDREE7EM/Xa+Bjtdotmo6iLFfXuTe
jrwdqF00AlGk1EW2HJ+8qr0abqQiacpES9d6sdf61iFAMT/3yBkNlY4ipRfpbQg0
Gncr2sL5t86kvUbnjKxrcvd8tNXTL79gM13bI0Vu9sVxmkpLl4vseTXMSGQF0NRp
F9dUU1vka1wUi3/cxiW3FUj/P4hKgmI3EqhzZuVraePSaazX8/dX+mbU75rfIGrT
ln+ITBXzjv/0WBJWESkcb35+Y/jXSz9+0Sco/rlcvP1+v/kF55W/5fxE1pXYtMSB
4wL5oNlYrATcwI6LpI+01C8tY9tsSW61aVdinzUCTRm+vI4xTXrLz5qvA9IeuqKc
ePVfxWcyR9xmAnt72t7R
=5iKA
-----END PGP SIGNATURE-----

--=-ztw/TBEd1Vw4sQECYlTr--
