From: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [net-next PATCH v3 4/5] fm10k/igb/ixgbe: Replace
 __skb_alloc_page with dev_alloc_page
Date: Tue, 11 Nov 2014 09:56:34 -0800
Message-ID: <1415728594.2466.173.camel@jtkirshe-mobl>
References: <20141111172523.16460.16845.stgit@ahduyck-vm-fedora20>
	 <20141111172657.16460.60596.stgit@ahduyck-vm-fedora20>
	 <1415726904.2466.170.camel@jtkirshe-mobl>
	 <20141111.124826.2036471212277751765.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-wLnZOKqc4vsA6cI3Pg/U"
Cc: alexander.h.duyck-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org, matthew.vick-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	mgorman-l3A5Bk7waGM@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141111.124826.2036471212277751765.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-wLnZOKqc4vsA6cI3Pg/U
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-11-11 at 12:48 -0500, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Date: Tue, 11 Nov 2014 09:28:24 -0800
>=20
> > On Tue, 2014-11-11 at 09:26 -0800, Alexander Duyck wrote:
> >> The Intel drivers were pretty much just using the plain vanilla GFP
> >> flags
> >> in their calls to __skb_alloc_page so this change makes it so that
> >> they use
> >> dev_alloc_page which just uses GFP_ATOMIC for the gfp_flags value.
> >>=20
> >> Cc: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> >> Cc: Matthew Vick <matthew.vick-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> >> Cc: Don Skidmore <donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> >> Signed-off-by: Alexander Duyck <alexander.h.duyck-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> >> ---
> >>  drivers/net/ethernet/intel/fm10k/fm10k_main.c |    2 +-
> >>  drivers/net/ethernet/intel/igb/igb_main.c     |    2 +-
> >>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 +--
> >>  3 files changed, 3 insertions(+), 4 deletions(-)
> >=20
> > Thanks Alex, I will add the patch to my queue.
>=20
> I think this entire series will need to go via my tree, because the
> conversions are all required for patch #5 which removes the replaced
> interface altogether.

That is fine Dave, I think I mentioned that during Alex's v1 of the
series.  I was just letting Alex know that we were going to test his
changes, but feel free to pull the entire series.

I will give you my ACK

Acked-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

--=-wLnZOKqc4vsA6cI3Pg/U
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUYk3SAAoJEOVv75VaS+3OUhUP/0GeKaBUqFfJweBkvL5BQWGH
sZHWJribW28kWYkj/ICqlhisChZy+8wk1TftCqjvvNILCdSmZRtoz6e4GKul0J/x
tIzgzfl5nhVM+RRZkbift8FwX3LTGAy4WR/J3DQvU1atynzzCZgLt4TzhTt10y+5
JNdWIz+Hiqg8m3dVRmUjKk41FGBNqoPduiUf535UC1Xoh61EI7MAD95mb0bKATXA
7RlVCtSaR2xBkbacD+lNqzbojNsMENrjV4MU86nLzDAfPe0JWQhSs9FZmo8GeFoH
c6CyUcJXaEAeqvCx77VrzdKyCxyONONp6Xjr9C0Mq6YKjYxeJwxaq840sPL8JDqT
pAPQWLcRgfscFTwe4bFTZ+J6ohPpInI/LKltSwqAlFPDrAOSyg6S1/vrttLGhjRx
9Ga7p9Nt51GqYpHtBb2RtXpcCZXuaxXOjq2gTcFjbGTBaWYwyJdMd0N5KX24U3xW
s9SD0gbvCwN0s8TNqn1PGozUEyjNfSwh23FwbcqUQSTJ8fWsGlRvMd9l1EsTLMkB
P6pTFodxNWDr3ZjX21P47mbkHaFtQJH4LTqvUjET78+InGkdLkiy6w5RDFKeLpQH
5V7WEwv3DGG8HqDbr1aH5UCRnACtHnHLq4pwOFTxjgpNKPNtF67zczcH+HeypsLD
SWlkUpbYuS1XBPVG6ZCd
=IhAg
-----END PGP SIGNATURE-----

--=-wLnZOKqc4vsA6cI3Pg/U--

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
