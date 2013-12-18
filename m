From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the net-next tree with Linus' tree
Date: Wed, 18 Dec 2013 13:19:39 +1100
Message-ID: <20131218131939.edf8a9f73b9af441773afe0d@canb.auug.org.au>
References: <20131218124657.f573d9ae178ea37fa971456d@canb.auug.org.au>
	<1387331769.2330.12.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__18_Dec_2013_13_19_39_+1100_si/N.VWoid.nhb5M"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Anjali Singhai Jain <anjali.singhai@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1387331769.2330.12.camel@jtkirshe-mobl>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__18_Dec_2013_13_19_39_+1100_si/N.VWoid.nhb5M
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jeff,

On Tue, 17 Dec 2013 17:56:09 -0800 Jeff Kirsher <jeffrey.t.kirsher@intel.co=
m> wrote:
>
> Your fix is fine, what I have in my tree is the following, so if you
> want to modify your change so that the resultant code looks like this:
>=20
>         struct rtnl_link_stats64 *vsi_stats =3D
> i40e_get_vsi_stats_struct(vsi);
>         int i;
>  =20
>         if (test_bit(__I40E_DOWN, &vsi->state))
>                return stats;
>=20
>         if (!vsi->tx_rings)
>                return stats;
>  =20
>         rcu_read_lock();
>         for (i =3D 0; i < vsi->num_queue_pairs; i++) {

OK, I updated my rerere cache, so it will look like that tomorrow.

Thanks.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__18_Dec_2013_13_19_39_+1100_si/N.VWoid.nhb5M
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSsQZAAAoJEMDTa8Ir7ZwV+JkP/1yvYRsnrFJ8fvbV/pHw0Frg
Vzrg346SDmNFlDoXWijiJ4a1mwfLFho0rL/I3BBzsCHk3xXuMBtnobNqR1hFPK2e
DC7dylfpgWu4efYQEl1ttPY0chxjQA9TaU4Ym3GrL41MSGtkQy9NG5x9drr7o2p+
b0vKKdXvuDUG68J6OMBuahlHVUMExUXYTf3r2teLFpn9QdGA5GC7eowdFF+7lxSg
tiOBRHJ0/im0wgDO2BZTMKPlqk43eZdbp6VXPfJDnPGacyXYkWPEvDBnVOeZBbha
mAleG1EX/2YaICWgiybiM32UK+FYK4+1G+Osi7FkydQfecCZDPcxv9zWRqdUeOJe
8eyqUQU81FjrAZBiwY6yVwvR/ARy4WKk2Hz8Gpumt44mRQza4neUhDDgEfGb38J/
h/ovMk00IVK95YgOu/H1jtnd3Y8Rxk6mf63D5PUbyBIXe/p6lGIa4agnyt5imZO9
VzSuu6foKiM0d+o1KhacVu+FOFD4W/jbaQc8N8KcsLqBZYU9AIbpskIbmz4lYfMT
nxMCkPGzmLB1pmgHKAIG6fn3n/3UyKGkDLUMs7NTt54IJM59xuxYEMjcedC9ph8H
C9QE2X0lQOU9XeTD8zlxcIyUF/p2X/3vzdTy3a8NVAphvn2ivYh9Z7Zh2gELfW1R
mFUK1Qw5iQOcE6Ahron0
=w193
-----END PGP SIGNATURE-----

--Signature=_Wed__18_Dec_2013_13_19_39_+1100_si/N.VWoid.nhb5M--
