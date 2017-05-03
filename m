From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 1/1] IB/mlx5: Add port_xmit_wait to counter registers read
Date: Wed, 3 May 2017 08:38:00 +0300
Message-ID: <20170503053800.GB22833@mtr-leonro.local>
References: <20170501163008.27043-1-tim@binbash.co.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="CUfgB8w4ZwR/yMy5"
Cc: <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Tim Wright <tim-r/Uwd3QrhQcqdlJmJB21zg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170501163008.27043-1-tim-r/Uwd3QrhQcqdlJmJB21zg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--CUfgB8w4ZwR/yMy5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, May 01, 2017 at 05:30:08PM +0100, Tim Wright wrote:
> Add port_xmit_wait to the error counters read by mlx5_ib_process_mad to
> ensure sysfs port counter provides correct value for PortXmitWait.
> Otherwise the sysfs port_xmit_wait file always contains zero.
>
> The previous MAD_IFC implementation populated this counter, but it was
> removed during the migration to PPCNT for error counters (32-bit only).
>
> Signed-off-by: Tim Wright <tim-r/Uwd3QrhQcqdlJmJB21zg@public.gmane.org>
> ---
>  drivers/infiniband/hw/mlx5/mad.c | 2 ++
>  include/linux/mlx5/mlx5_ifc.h    | 4 +++-
>  2 files changed, 5 insertions(+), 1 deletion(-)
>

Thanks,
Acked-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

--CUfgB8w4ZwR/yMy5
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkJbLgACgkQ5GN7iDZy
WKfa5g/+Jotw4e92rVENtcz8Nc+a9hwCrv033C+pDqkiUobGCFHK5OeUeBFjT2WZ
2VGnId9k5Gog5hqJg66rZ3LdR8At+n5QGJebI+8m8/IV26T3Xtjn2FbbAF9bgx6R
OsyV1WhUAcjUZFMzkoBq15FAB5UK8dDZcS6Am9NctTumrZoZ/ZP3LspuYhQ2L5sg
kBrLRZTRdmHxT0maEG4eU2TSd5zmpOKWZv2brWEE/OehAb7bCPrQPT8/ljGYS3FU
GLb2SDB0HFCesyJX1spmBWGm9mc5UtHe6x3JPXt0LOLYoEcYiWCN86ms5WrgcDnE
36hk7ree2sdxCRYf/jk+a1tEofeYwp/MTlmfsrXDm3jqA4tlskEfQLQg61g+8XRK
ZK0kXb3xJd3Toij/c5svk6dX5Y2zRDBN7UVu3+lT4xA12oyNdg4ooGYwmbWxM7Pd
ePpEe1OOgciAUs/0CtssCfbee9ixuLSAP8a4t6/E8AwHC+0EQ0ln+7HZK2y24bF1
AgTslqudNfUqRekVGDYNgkOt309meMze8yhNtQx/D8kxKERpULNGkAjCJpx6xQjL
KVx+Udt7JsSwTRUFEKZXrYOe01R0dTxzF3SjwPdajD/0J9gUFY8Bri4t999rO6nK
mj+qXbdjUtVdvK2LyxY4JfG9rqn7YQjQaaj5ct/8MAZw/h0K1i8=
=rEcE
-----END PGP SIGNATURE-----

--CUfgB8w4ZwR/yMy5--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
