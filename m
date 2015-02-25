From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [E1000-devel] [PATCH] ixgbe: make VLAN filter conditional in
 SR-IOV case
Date: Tue, 24 Feb 2015 23:20:39 -0800
Message-ID: <1424848839.2553.34.camel@jtkirshe-mobl>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05D9D336@BPXM14GP.gisp.nec.co.jp>
	 <1415898512.2454.26.camel@jtkirshe-mobl>
	 <7F861DC0615E0C47A872E6F3C5FCDDBD05E3F3CE@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-rZaCBLGw/UKfkYU4r2+O"
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E3F3CE@BPXM14GP.gisp.nec.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-rZaCBLGw/UKfkYU4r2+O
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-02-25 at 00:51 +0000, Hiroshi Shimamoto wrote:
> > Subject: Re: [E1000-devel] [PATCH] ixgbe: make VLAN filter
> conditional in SR-IOV case
> >=20
> > On Thu, 2014-11-13 at 08:28 +0000, Hiroshi Shimamoto wrote:
> > > From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> > >
> > > Disable hardware VLAN filtering if netdev->features VLAN flag is
> > > dropped.
> > >
> > > In SR-IOV case, there is a use case which needs to disable VLAN
> > > filter.
> > > For example, we need to make a network function with VF in
> virtualized
> > > environment. That network function may be a software switch, a
> router
> > > or etc. It means that that network function will be an end point
> which
> > > terminates many VLANs.
> > >
> > > In the current implementation, VLAN filtering always be turned on
> and
> > > VF can receive only 63 VLANs. It means that only 63 VLANs can be
> used
> > > and it's not enough at all for building a virtual router.
> > >
> > > With this patch, if the user turns VLAN filtering off on the host,
> VF
> > > can receive every VLAN packet.
> > > The behavior is changed only if VLAN filtering is turned off by
> > > ethtool.
> > >
> > > Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> > > CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> > > ---
> > >  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 10 ++++++++++
> > >  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |  4 ++++
> > >  2 files changed, 14 insertions(+)
> >=20
> > Thanks Hiroshi, I will add your patch to my queue.
>=20
> How about this patch?
> It hasn't been in your tree,.
> Is there any issue?

This patch was dropped for two reasons.  First was Ben Hutchings issues
with the patch needed to be addressed.  Second, was due to a possible
security hole which is why VLAN filtering was not disabled in SRIOV
mode, where isolation is lost between VMs.

If you want to continue going forward with this change, a warning
message should be added, at least, warning the user of the possible
security issues.

--=-rZaCBLGw/UKfkYU4r2+O
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU7XfHAAoJEOVv75VaS+3OugsP/A1a9K4+xCe1/MOJxmHr6lsh
CuqnXLaROBlQKZsW7GgAfq+U8ltgQaATKTptR0+Ot9TuBDmXNbhw9Ux6iM97iE2m
MO2zchXFbmd/CJzFtCGy6fdpa+ja7vyHBsYfFUZwr5YSugwO88pElqEnKKR7uIcg
xKTtNtuglag8q/9hJWFCEGHAa+YtdHGOhvkNFloM83Bg69EUJlvIet0H5fwom38k
uijw0mMU/i8WiK59Poah76M/biW3ds3sDUJ9h9XSV1FnOzlxqHFQHhdGMVzu3SBq
UCuoefUeAOQXVYe/7In8QtTS1vtg+U9YPmSjahZt+5rbg2F1+TIef1A9xeFr5qCz
XOxiW11g6rTMhrtUI8+u7PIeEJtQh6j/G5tqNLxh2GHAwixl+kxgKVZDBB8BKrRm
XjKhCWvy3YxHiz20Fa+By69zlP/+9DrW5XfV/ndxvMsoZ92+SZWYVpnDgIClBg6w
NtoxWh/WZZodufTVfj7Rj0zoqf6U+fppYgM2VdRaw2Xm8COCZt84AWjK662d+/OT
RGmGFnr3tmtZ+JACeVnxBma7dV4FezJ8fZKs7PrEoesGTOHdOs2ku3FeS8eeo6e4
ZIShKznGIzozZCjyjDpnETBqd6ySs3CRWZtTHC5LUPxydh+xPBuQ2DQJjstd541a
8X9hSoaufwz3xVhw73iH
=mXPV
-----END PGP SIGNATURE-----

--=-rZaCBLGw/UKfkYU4r2+O--
