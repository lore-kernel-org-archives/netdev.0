From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v10 06/22] IB/hns: Add initial cmd operation
Date: Mon, 20 Jun 2016 16:33:10 +0300
Message-ID: <20160620133310.GB4526@leon.nu>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-7-git-send-email-oulijun@huawei.com>
Reply-To: leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="CdrF4e02JqNVZeln"
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1466087730-54856-7-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--CdrF4e02JqNVZeln
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 16, 2016 at 10:35:14PM +0800, Lijun Ou wrote:
> This patch added the operation for cmd, and added some functions
> for initializing eq table and selecting cmd mode.
>=20
> Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
> Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
> PATCH v9/v8/v7/v6:
> - No change over the PATCH v5
>=20
> PATCH v5:
> - The initial patch which was redesigned based on the second patch
>   in PATCH v4
> ---

<...>

> +#define CMD_MAX_NUM		32
> +
> +int hns_roce_cmd_init(struct hns_roce_dev *hr_dev)
> +{
> +	struct device *dev =3D &hr_dev->pdev->dev;
> +
> +	mutex_init(&hr_dev->cmd.hcr_mutex);
> +	sema_init(&hr_dev->cmd.poll_sem, 1);
> +	hr_dev->cmd.use_events =3D 0;
> +	hr_dev->cmd.toggle =3D 1;
> +	hr_dev->cmd.max_cmds =3D CMD_MAX_NUM;

<...>

> +	for (hr_cmd->token_mask =3D 1; hr_cmd->token_mask < hr_cmd->max_cmds;
> +	     hr_cmd->token_mask <<=3D 1)
> +		;
> +	--hr_cmd->token_mask;

It doesn't look that you dynamically change max_cmds supported.
Why do you need to calculate token_mask dynamically?

--CdrF4e02JqNVZeln
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXZ/CWAAoJEORje4g2clin6fYP/3irrJtA/mvfhiD+6U3rDRoN
9p5rvft5GKojFbqPNLaG7XrlKDpTgRhVVuyzjlxWSk0/P+XmdXBiRaUPESfeRf5d
fPaqJQ5LP1tyo1i24c9lla7ZIUFPvdd7kKWZrP2CdqlJAgqJ2ZNuuqoP3k2gq8OT
VE8zMH5INdwBoq3av5iUdJKGLSlV0YlOFOdJALjjkYelCIsy9WWVA7rJ6YXqzscG
3V/D5T6JmHP4EoD7kbaExF7SknE9kOzESjMWH1BpG00hCl0yicaPy4Ftk3vu0IU+
pyYf+moyhExcBwlNpXWejuXzfFtgygTs5+vbXu20bvHY9xhjOa3GI+Qbotk7GdHV
3KNfjsjttsoFozd8jKV6RqvywnY2f6iT1E9xNtiDJZ2g00EWrm+CdAYbz8jzbSpm
UsLkzZ/5Lqv2NzW4fcP1PQNadjefowcZV6DL5mmsfSKt1if9SKIE6K9n/hUr8iy3
vC+hV7iNSSr5skDrzQ++6+OOKA28xse8cV6eeuv0uxgh1xeF1c8ZHp175AC636fW
Ti0C2AFZA6c/j2oSLz+2s13t5PVTZOPh3Z3voGQRDnzD95u9AEVb2VasGD0Ko95E
sb6yoqSpE3PNiNA7Ga7gK72b3JUG/Bc2jhT0zaN46Bbmaue0a52Zq2dmvbPSi6OK
lYd6HEGV4qjptp4UP3kI
=yDFm
-----END PGP SIGNATURE-----

--CdrF4e02JqNVZeln--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
