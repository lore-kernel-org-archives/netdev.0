From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [linux-nics] linux-next: Tree for Aug 11
 (net/ethernet/intel/i40e)
Date: Mon, 11 Aug 2014 15:16:32 -0700
Message-ID: <1407795392.2189.13.camel@jtkirshe-mobl.jf.intel.com>
References: <20140811155213.0aa083ce@canb.auug.org.au>
	 <53E8ECA9.6060806@infradead.org>
	 <1407786786.2189.0.camel@jtkirshe-mobl.jf.intel.com>
	 <20140811.145454.185028525560881583.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-sjR+vxTll9NccxAxRr92"
Cc: rdunlap@infradead.org, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux.nics@intel.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140811.145454.185028525560881583.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-sjR+vxTll9NccxAxRr92
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-08-11 at 14:54 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Mon, 11 Aug 2014 12:53:06 -0700
>=20
> > On Mon, 2014-08-11 at 09:17 -0700, Randy Dunlap wrote:
> >> On 08/10/14 22:52, Stephen Rothwell wrote:
> >> > Hi all,
> >> >=20
> >> > Please do not add code intended for v3.18 until after v3.17-rc1 is
> >> > released.
> >> >=20
> >> > Changes since 20140808:
> >> >=20
> >>=20
> >> on i386 and x86_64:
> >>=20
> >> ../drivers/net/ethernet/intel/i40e/i40e_fcoe.c: In function
> >> 'i40e_get_fcoe_tc_map':
> >> ../drivers/net/ethernet/intel/i40e/i40e_fcoe.c:354:23: error:
> >> 'IEEE_8021QAZ_APP_SEL_ETHERTYPE' undeclared (first use in this
> >> function)
> >>    if (app.selector =3D=3D IEEE_8021QAZ_APP_SEL_ETHERTYPE &&
> >>=20
> >>=20
> >> Needs to #include <uapi/linux/dcbnl.h> ??
> >=20
> > Yeah, Dave has already accepted a patch to resolve that, which I believ=
e
> > went into his net tree.
>=20
> I see no such change in my tree.

http://patchwork.ozlabs.org/patch/376699/

This is what I was referring to, it looks like you set the patch status
to "Awaiting upstream" yet you responded that you applied it.  So my
bad, I thought you had already sucked it into you tree.  I get this
resolved and send you this and a few other fixes later today.

--=-sjR+vxTll9NccxAxRr92
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJT6UDAAAoJEOVv75VaS+3O+0EP/1nQwfiNghl0oBB3VJifrEc4
VrvVNO7/Xz94mbIcFOECvGzDz7ybHAcTBvGbAdRBB4FSJKMll4/CivkEXvr/wFiH
znr4SQJTQ3/4qLBYY3AoBBckpGZo2+bKn3R9noUISoqo0srg5mvM/lnLB2moRTz0
djs2EK9ueS8RsnsIciqSD2ybgwEKs+xKbl5p9DBcSNXjgGMzvyr3JdaFp9UT56Td
/LfKDXyWxKauLmPVUe3gx/+453DNO+89CMUrfMPYi/oQzikzlh0Jo7a9ljkI7mEj
nT5i1cSBb5jmMzR+bqjkeP+VmAHsWiNcKNG4/sDURUj2a9T1/yEihxV2AVOwd/Ki
kfmEUWy8/eZoPbC93nq1lTB/YkJmiJWqFTAXz3wUT5/vehisUzpamSwktfxUS6Cp
8EowgClbO0ufwszgwccEIOTl2nTyJipzYenldIvQJ3+oPDRyQzYK0PiYID7ZfINI
z7S51eJAXcYyjU4rvlA3ypWRQBdG7WxQz1CbewNeH6OUqFZdmHZ6PjetaT5r25o5
eL+eE0kM1ZQ39lxlYLR9L8nMiKNpMemSAPylheme/DHfv4n0aSQCmNHdG/lBn/Xn
lix4K0Zf7bZZVjUpvxjpWFuoLLCPTwkl9SR/9C6sx8UOym6Lh9ku2XG2V3oxP5x0
sB+VV+J8WBjmVg8Sqcn+
=2nM2
-----END PGP SIGNATURE-----

--=-sjR+vxTll9NccxAxRr92--
