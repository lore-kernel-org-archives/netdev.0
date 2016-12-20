From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [PATCH] net/mlx5: use rb_entry()
Date: Tue, 20 Dec 2016 16:19:36 +0200
Message-ID: <20161220141936.GX1074@mtr-leonro.local>
References: <ddabc96c798df194791134d8e070d728e2a7b59f.1482203698.git.geliangtang@gmail.com>
 <8443fa3fa03d82c2b829375d8020762e5236dc6d.1482203930.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="3rx43rDlPB5nB2+S"
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>, <netdev@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Geliang Tang <geliangtang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8443fa3fa03d82c2b829375d8020762e5236dc6d.1482203930.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--3rx43rDlPB5nB2+S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Dec 20, 2016 at 10:02:14PM +0800, Geliang Tang wrote:
> To make the code clearer, use rb_entry() instead of container_of() to
> deal with rbtree.
>
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Thanks,
Acked-by: Leon Romanovsky <leonro@mellanox.com>

>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
> index 3b026c1..7431f63 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
> @@ -75,7 +75,7 @@ static void mlx5_fc_stats_insert(struct rb_root *root, struct mlx5_fc *counter)
>  	struct rb_node *parent = NULL;
>
>  	while (*new) {
> -		struct mlx5_fc *this = container_of(*new, struct mlx5_fc, node);
> +		struct mlx5_fc *this = rb_entry(*new, struct mlx5_fc, node);
>  		int result = counter->id - this->id;
>
>  		parent = *new;
> --
> 2.9.3
>

--3rx43rDlPB5nB2+S
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlhZPfgACgkQ5GN7iDZy
WKeJ+hAAlSCSAtxBiHM84PF/F+Vd3LVyBs8x4nCuIWaHdRwPv7rQwvVbC6HoSFRz
aDGGgw74AV9AnYsmiLHtcIYOTFp/MIDY/b9wYhRi+Kowc/dJuwuD9fBpx2s/97v+
c69oJL1QkhUU7eYT6bKzrFAL43YFNM5QV6LcRBBuFgfCuHUw46iWBX/yrXb2tElM
9y2U1y8Cj4RWZ19IoF0YiWw8+S7R39WLUT4lCRJX7kvekP8Hd/xZI83q/8/Dpmr+
bgnudWnD1xx23Y6ncgG7mO3lSJaRJNOmmavCS4UZnDyuXUPvArtNueee7duAMnsE
fWBMjlQz9bqaCBela/myiJhrA/csAvcFbUhiqM3/NvhUwwQ7a6fOJ/0BT5aHfSfD
U1utFuQ4/cAftVks8BpZasUe+h75NSEQ6c5gA/cPDdSrKz1IqQChpV61ZwDb9qhD
MssxcjsSFLKmccUqbaLTG0Rtc4j83QsQRoYhV8jhMak3WthpHWHJr2mslyE8e1+Y
XHIYgu/eEK/IS5TiLVp3e0e50SRJkMrySa1AoPNEdU7poB84JgDan2pHxvSTHyTa
KhoQH3T+cEvvV87VJvAKz4wVWIOfHsMWMuvuEECc64Kb/dcwAd11SSeeFlCuvVpd
NdnT7yZ5ZjcHaWTFJAve0hcne/NaTYlRosZpRhZDKy64w/uV4fc=
=ZGfY
-----END PGP SIGNATURE-----

--3rx43rDlPB5nB2+S--
