From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Patch net] igb: fix a typo in igb_reset_q_vector()
Date: Tue, 21 Apr 2015 17:29:37 -0700
Message-ID: <1429662577.2638.201.camel@jtkirshe-mobl>
References: <1429658433-8634-1-git-send-email-xiyou.wangcong@gmail.com>
	 <5536EAA3.10701@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Uy5XvZJIj5yFbwKML6ey"
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:32236 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933696AbbDVA3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Apr 2015 20:29:38 -0400
In-Reply-To: <5536EAA3.10701@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Uy5XvZJIj5yFbwKML6ey
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-04-22 at 09:26 +0900, Toshiaki Makita wrote:
> On 2015/04/22 8:20, Cong Wang wrote:
> > Fixes: 5536d2102a2d ("igb: Combine q_vector and ring allocation into a =
single function")
> > Cc: Alexander Duyck <alexander.h.duyck@redhat.com>
> > Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> > ---
> >  drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >=20
> > diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/et=
hernet/intel/igb/igb_main.c
> > index 8457d03..85bbeb2 100644
> > --- a/drivers/net/ethernet/intel/igb/igb_main.c
> > +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> > @@ -1036,7 +1036,7 @@ static void igb_reset_q_vector(struct igb_adapter=
 *adapter, int v_idx)
> >  		adapter->tx_ring[q_vector->tx.ring->queue_index] =3D NULL;
> > =20
> >  	if (q_vector->rx.ring)
> > -		adapter->tx_ring[q_vector->rx.ring->queue_index] =3D NULL;
> > +		adapter->rx_ring[q_vector->rx.ring->queue_index] =3D NULL;
> > =20
> >  	netif_napi_del(&q_vector->napi);
> > =20
>=20
> Hi Cong Wang,
>=20
> I have already sent a patch to intel's tree.
> http://git.kernel.org/cgit/linux/kernel/git/jkirsher/net-queue.git/commit=
/?h=3Ddev-queue&id=3D02ac4b65689f8df824117395fd8d160c04161a7b
>=20
> Toshiaki Makita
>=20

Oops, yeah.  I already have this in my queue.  I wondered why the patch
seemed familiar, Cong dropping your patch since I already have
Tochiaki's patch in my queue.

--=-Uy5XvZJIj5yFbwKML6ey
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVNutxAAoJEOVv75VaS+3O3cIP/0ay7qR1WGo/yQ/fYpnL5PKD
y5Tl88jvCHBXblna6eQxr67ii6G1ghy4hrEOOy/Q6/OlWo+P28BI05rrdE8VbJ6/
8ufdMCVcwau5325ZeBIIDPt61lU3Um60irCa9F6FxgB852wc9nw+GXFlplA2OwIj
5cd+dF5iagL5vHp/0EDR/PuuSUPIjQ4NoExqLI63FFusB5kjUBhHjPiWPvCv6xfv
sD8/Gz9GbAm/P+Rc1GfrXDSdWWw0lILzGNxeAa0m9d9Ff0PiIrFlBJAVgYAS1hih
KaCUNkejcY3wfZAyEO1n0zdeBeC4H8xXZyZUqIKBT8F4AmdUMWwX1nx+yckSgWJ+
tG9vwcGR4OtTLhrI22U2PyzdRM9U8x50Xw/CDkvdfEwjlKqP45Mhw3JAk+AleEzb
nCLzkLuMZ9vGjWKT39KLL3r5At/sZKFEeKzBI9ixwcx3zIJVtBM7RYWsqhMLf6Tc
E3rniyjFT9AcKPesyuZ141T2qttPSsZ0yfGy0yczDprrklvp90orw3R8jvPX8UW2
87B6LXWxUoYpEDqkdvSSwIZT11JaUjO7t60Oy6XGnkjutX7wxvpPo1ZbyTbU81mY
21cdXepBEBsYnN24sowqwAdXw6u5ANTusGiq376jsZJhFFAKWjGv/TAP0q8qxzWJ
vWIVmC/9KygvxzQR1MN8
=Ya52
-----END PGP SIGNATURE-----

--=-Uy5XvZJIj5yFbwKML6ey--
