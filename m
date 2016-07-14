From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v11 21/22] IB/hns: Kconfig and Makefile for RoCE module
Date: Thu, 14 Jul 2016 08:35:31 +0300
Message-ID: <20160714053530.GJ10079@leon.nu>
References: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
 <1467452364-66522-22-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pMCBjikF2xGw87uL"
Cc: dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, jiri@mellanox.com,
	ogerlitz@mellanox.com, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gongyangming@huawei.com, xiaokun@huawei.com,
	tangchaofei@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, yankejian@huawei.com,
	charles.chenxin@huawei.com, linuxarm@huawei.com
To: Lijun Ou <oulijun@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1467452364-66522-22-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--pMCBjikF2xGw87uL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jul 02, 2016 at 05:39:23PM +0800, Lijun Ou wrote:
> This patch added Kconfig and Makefile for building RoCE module.
>=20
> Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
> Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
> Signed-off-by: Lijun Ou <oulijun@huawei.com>
> ---
> PATCH v11:
> hns_roce_icm.o -> hns_roce_hem.o
>=20
> PATCH v10/v9/v8/v7/v6/v5:
> - No change over the PATCH v4
>=20
> PATCH v4:
> This fixes the comments given by Christoph Hellwig over the PATCH v3:
>   Link: https://lkml.org/lkml/2016/3/22/609
>=20
> PATCH V3:
> This fixes the comments given by Leon Romanovsky over the PATCH v2:
>   Link: https://lkml.org/lkml/2016/3/20/5
>=20
> PATCH v2:
> This fixes the comments given by Leon Romanovsky over the PATCH v1:
>   Link: https://lkml.org/lkml/2016/3/6/94
> Fixes the error tested by kbuild test robot over the PATCH v1:
>   Link: https://lkml.org/lkml/2016/3/4/343
>=20
> PATCH v1:
> - The initial patch
> ---
> ---
>  drivers/infiniband/Kconfig         |  1 +
>  drivers/infiniband/hw/Makefile     |  1 +
>  drivers/infiniband/hw/hns/Kconfig  | 10 ++++++++++
>  drivers/infiniband/hw/hns/Makefile |  8 ++++++++
>  4 files changed, 20 insertions(+)
>  create mode 100644 drivers/infiniband/hw/hns/Kconfig
>  create mode 100644 drivers/infiniband/hw/hns/Makefile
>=20
> diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
> index 2137adf..767f92b 100644
> --- a/drivers/infiniband/Kconfig
> +++ b/drivers/infiniband/Kconfig
> @@ -74,6 +74,7 @@ source "drivers/infiniband/hw/mlx5/Kconfig"
>  source "drivers/infiniband/hw/nes/Kconfig"
>  source "drivers/infiniband/hw/ocrdma/Kconfig"
>  source "drivers/infiniband/hw/usnic/Kconfig"
> +source "drivers/infiniband/hw/hns/Kconfig"
> =20
>  source "drivers/infiniband/ulp/ipoib/Kconfig"
> =20
> diff --git a/drivers/infiniband/hw/Makefile b/drivers/infiniband/hw/Makef=
ile
> index c0c7cf8..2ad851d 100644
> --- a/drivers/infiniband/hw/Makefile
> +++ b/drivers/infiniband/hw/Makefile
> @@ -9,3 +9,4 @@ obj-$(CONFIG_INFINIBAND_NES)		+=3D nes/
>  obj-$(CONFIG_INFINIBAND_OCRDMA)		+=3D ocrdma/
>  obj-$(CONFIG_INFINIBAND_USNIC)		+=3D usnic/
>  obj-$(CONFIG_INFINIBAND_HFI1)		+=3D hfi1/
> +obj-$(CONFIG_INFINIBAND_HISILICON_HNS) 	+=3D hns/

--------------------------^^^^^^^--
There is no need in HISILICON word here.

> diff --git a/drivers/infiniband/hw/hns/Kconfig b/drivers/infiniband/hw/hn=
s/Kconfig
> new file mode 100644
> index 0000000..c47c168
> --- /dev/null
> +++ b/drivers/infiniband/hw/hns/Kconfig
> @@ -0,0 +1,10 @@
> +config INFINIBAND_HISILICON_HNS
> +	tristate "Hisilicon Hns ROCE Driver"

And you are still inconsistent with the names
Hisilicon/HiSilicon/hisilicon/HISILICON/e.t.c., ROCE/roce/RoCE/e.t.c.

--pMCBjikF2xGw87uL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXhySiAAoJEORje4g2clinj4IP+wRq+hEbjDzVuQCr+xGIltsk
q3LgjZsEUnn2+KclRycnhANvYJhZ4+hfMyhjtba17lJASLwezrO4XuKiNmFiookf
ofSmKKOoSWalilVhzYgHCOBIbvxLmmYHw12LVEkmUJtv6SqbkbxJfhxD3gYO2xpR
P4xXCBG65bXOMOcxfRwtAPA68RpD9KdUzit7oJZxWmQT3IPieXC015DuQQZSMnqA
D+Y5SBIfIpUP/iI6E+c6O+/TRnFLCkWNTj5pMrXYQBpuFSrNZ/sisutRVkRsV9XX
Qf9EQzSuTAdhvkeQfFA2sChM3AYTbVXte1ReZU5acBKm0nGj3lhnq0XmiMTf8WjX
tislGkYN4XTXCmSTBr3PThqO4k/gXUWDTd2aBCmjhurAPsJZ+psjqNw3gJjG2x0W
/rhavfxrcY08z96C2fm4QkYMeHKHtx1mTB8h3PI58YuU2gws5lWwOoNXJbBBfWyw
VWTF75kga8rlw3xKiK/gSqGGR5faVIkFIw9NLUHzaUn8zIfVMYRLEFPtWi0ak+eR
yQ4UUofEOqR+ara1xpCrPqlV7vFbHr1G3qUPfzG1zS7rom2gPXxzj3H48immV3ow
wrt6uqHKPBNab3sTgdTwz/tRur3UhoCGqUcGfVY7DP6GK8boMcMmgvb1hrhfc0gY
udK+CCXFmiYocm/m0gwt
=nhZK
-----END PGP SIGNATURE-----

--pMCBjikF2xGw87uL--
