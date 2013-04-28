From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 29 Apr 2013 09:57:35 +1000
Message-ID: <20130429095735.bbc99fd1444dbd756b645979@canb.auug.org.au>
References: <20130426132447.c7b06622240088ccad366b03@canb.auug.org.au>
	<20130428164933.6d3da501@lb-tlvb-yuvalmin.il.broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__29_Apr_2013_09_57_35_+1000_IhBNHIdThyCbtaL3"
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Yuval Mintz" <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:51884 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756538Ab3D1X5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Apr 2013 19:57:47 -0400
In-Reply-To: <20130428164933.6d3da501@lb-tlvb-yuvalmin.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Mon__29_Apr_2013_09_57_35_+1000_IhBNHIdThyCbtaL3
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Sun, 28 Apr 2013 16:49:33 +0300 "Yuval Mintz" <yuvalmin@broadcom.com> wr=
ote:
>
> > Today's linux-next merge of the net-next tree got a conflict in
> > drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c between commit
> > ecf01c22be03 ("bnx2x: Prevent NULL pointer dereference in kdump") from
> > the net tree and commit 5b0752c863d7 ("bnx2x: Fix VF statistics") from
> > the net-next tree.
> >=20
> > I am not sure about this, but I just used the net tree version but I
> > assume something more may be needed and can carry the fix as
> > necessary (no action is required).
>=20
> This patch adds the missing functionality from the `net-next' patch
> which was lost due to the merge.

Thanks.

> Is `linux-next' the correct tree to send it into?
> (I couldn't designate it to `net-next' as the merge between `net' and
> `net-next' hasn't occured yet, thus no collision there)

I have added this hunk to the merge conflict resolution in linux-next.  I
assume that Dave will do this as well when he merges the net tree into
the net-next tree.

> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c index
> 06dee5c..52cf71c 100644 ---
> a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c +++
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c @@ -6053,6 +6053,8
> @@ void bnx2x_pre_irq_nic_init(struct bnx2x *bp) bnx2x_init_def_sb(bp);
>  		bnx2x_update_dsb_idx(bp);
>  		bnx2x_init_sp_ring(bp);
> +	} else {
> +		bnx2x_memset_stats(bp);
>  	}
>  }

This patch was badly corrupted ...

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__29_Apr_2013_09_57_35_+1000_IhBNHIdThyCbtaL3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRfbdwAAoJEECxmPOUX5FE0yoQAIJIsSrsLSmo+YhehLy41WDy
8OqvmI1RxAlqTKf/jYi9V5snt/UFfg3JPjZch9Khi4qF1YHRSVsJZIJw6F71hmKQ
cWlQPS8d9pgJa2OggG/SHCZgEhF1j2uyWK56Frvai95Sh4+rEwnYVUvOcHmXdJCU
dszLt8ZN6Gna3lMtPKIlj7hsz7ioxeTbHiUQUb48ZhONA2yp462Hn30Z7B84kreA
94Zx5sTd8+HdNBMygg0qxikYjioATldgXLbO8ROXnBxInYhaOtpIUk++nWKL61FP
g6myCiovbdgbJQjAeE0YFpEksHKqHzuQ1oD+kjRLk+eoCwwZbxF3kCf7WI1pYeOF
vt8Q40cE9HIm14MeTAxZrVnqV92HYAAXB3rw5feLRuWGJqxREUDC5xWdamXMvLLE
9iwxk61O1AzZn+dAWVT6P4CMCFgCPBlswBAbzppEXyOBKbLTQ62qCrP0Cq5jOkZO
CwU+3Sac1EVdtjOSpPkESo1eSjWqRYDcd8WyB0dioktesviDxQzyB1ehjXgzTgkd
GHr+B5eS99KbV2DY4KUJ3wuLHgDUKfrh8CzUF9c1u2Lks275wqUQsN5DtbEx3pT4
eWBinnNM22nOTrIOckianC+nWoINUq2FbvFWF+3ZZodBNWc9JQEDMKj5zkbedbAZ
98HwuvdGGtbaxbNBpWN1
=Bpma
-----END PGP SIGNATURE-----

--Signature=_Mon__29_Apr_2013_09_57_35_+1000_IhBNHIdThyCbtaL3--
