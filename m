From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v10 08/22] IB/hns: Add icm support
Date: Tue, 21 Jun 2016 14:55:54 +0300
Message-ID: <20160621115554.GB9762@leon.nu>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-9-git-send-email-oulijun@huawei.com>
 <20160617095834.GA5408@leon.nu>
 <57677314.70909@huawei.com>
 <20160620060614.GC1172@leon.nu>
 <5767A004.4060808@huawei.com>
 <20160620092719.GE1172@leon.nu>
 <5767BBDF.6010309@huawei.com>
 <20160620130422.GA4526@leon.nu>
 <5768C493.6000300@huawei.com>
Reply-To: leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Bn2rw/3z4jIqBvZU"
Cc: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: "Wei Hu (Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5768C493.6000300-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--Bn2rw/3z4jIqBvZU
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jun 21, 2016 at 12:37:39PM +0800, Wei Hu (Xavier) wrote:
>=20
>=20
> On 2016/6/20 21:04, Leon Romanovsky wrote:
> >On Mon, Jun 20, 2016 at 05:48:15PM +0800, Wei Hu (Xavier) wrote:
> >>
> >>On 2016/6/20 17:27, Leon Romanovsky wrote:
> >>>On Mon, Jun 20, 2016 at 03:49:24PM +0800, Wei Hu (Xavier) wrote:
> >>>>On 2016/6/20 14:06, Leon Romanovsky wrote:
> >>>>>On Mon, Jun 20, 2016 at 12:37:40PM +0800, Wei Hu (Xavier) wrote:
> >>>>>>On 2016/6/17 17:58, Leon Romanovsky wrote:
> >>>>>>>On Thu, Jun 16, 2016 at 10:35:16PM +0800, Lijun Ou wrote:
> >>>>>>>>This patch mainly added icm support for RoCE. It initializes icm
> >>>>>>>>which managers the relative memory blocks for RoCE. The data
> >>>>>>>>structures of RoCE will be located in it. For example, CQ table,
> >>>>>>>>QP table and MTPT table so on.
> >>>>>>>>
> >>>>>>>>Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> >>>>>>>>Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
> >>>>>>>>Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> >>>>>>>>---
> >>>>>>><...>
> >>>>>>>
> >>>>>>>>+
> >>>>>Another question which you didn't answer [1].
> >>>>>
> >>>>>"I wonder if you have the same needs for ICM as it is in mlx4 device.
> >>>>>Do you have firmware?"
> >>>>>
> >>>>>[1] http://marc.info/?l=3Dlinux-rdma&m=3D146545553104913&w=3D2
> >>>>Hi, Leon
> >>>>     Now we haven't firmware.
> >>>>     But hardware still need memory for QPC\CQC\MTPT\mtt etc.
> >>>ICM stands for InfiniHost (Interconnect) Context Memory is a specific
> >>>memory place to share between host <-> FW and host <-> HW if HW is
> >>>aware of specific structures.
> >>>
> >>>I assume that in your case, it is enough to allocate memory region and
> >>>supply it to HW. Am I right?
> >>For Our hardware,
> >>1. ICM has a memory management method, It's very good for QPC\CQC\MTPT\=
mtt
> >>etc. we need it.
> >You need special HW to leverage its. AFAIK it is Mellanox specific.
> For our hardware, we use ICM to memory management, the memory shared with
> host and HW.
> QPC\CQC\MTPT\mtt has specific memory requirement.
> QPC\CQC\MTPT need continuous memory. we use ICM to management the block of
> memory. It's very good=EF=BC=81

I wasn't convinced why do you need to copy whole ICM logic which is
specific to Mellanox. Your requirements can be implemented by standard CMA
and/or DMA.

> >>2. The meomry for QPC\CQC\MTPT\mtt only used for RoCE hardware and driv=
er,
> >>we don't want use MR.
> >I didn't mean Infiniband MR, but memory region returned from standard
> >allocation functions (kmalloc, ...).
> >
> >>3. Now we haven't firmware, maybe we need it next version.
> >You are always invited to add support once it will be needed, no need to
> >add it in advance.
> >
> >Thanks
>=20
>=20

--Bn2rw/3z4jIqBvZU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXaStKAAoJEORje4g2clinZKQP/2w6OPnlEhhNCVXWLIW9J9sH
Uy4+JdzDQJwFx6IuGTFrJ7gnA/gXImwrA5zmFYF3hiL8vkkFhZPKw2jM5eKzVc1/
wSVpYKrwOeE5mu3gWzvL9NWGz2qdUZd/InGVzxN9NAyT1GiJo57B9RqDyXE87fnS
yBph7dKlugbioEX/EF4m6GsEtbSNJlZmNF/CB7nsukTrglAAudN/dZD9D9AVFXVH
Hduj/dxo+iuvgujchtfbXBvUvDaNOkFcA2CDPfmk2P0of1DvGhkhtzWTyXHf6MjX
wNHy8viqqq0LINAwndPYq8siSaCzCVxV2E1HKQwJmvpArGmhuBeaWO5zNdZ2sL/V
/08OPrp3ayUloJw3tYup5cOaycWELN9rhAqg+I4dZMSFBHnwdScSZktclnCLeJLM
Z+5MmqeMs0ro/4DvKD6D2wFLVkqLUHvSewvItN0cUj1Is+H1tsKF36CH8QsX5zB+
BZ0s120rkjqvno9eL0NXK7lOiyyigQeg6C+/HWBNA7xotXOL3TerFlCTZup+DH7v
MwmA3HJK29fQPUYlKUEfOc+daak7op3EbwwRnLt16H3weha64/YMtqZjQLBU/IN8
v8Tl2q/rStZAG5PjKAl5KIUACs00O8q1cu2p85HsstHUnE2lYKbpgnKPxm3cWPWx
wN9UPIh8YPUHQZtXMAaY
=MxMy
-----END PGP SIGNATURE-----

--Bn2rw/3z4jIqBvZU--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
