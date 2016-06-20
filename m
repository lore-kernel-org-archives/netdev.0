From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v10 08/22] IB/hns: Add icm support
Date: Mon, 20 Jun 2016 16:04:22 +0300
Message-ID: <20160620130422.GA4526@leon.nu>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-9-git-send-email-oulijun@huawei.com>
 <20160617095834.GA5408@leon.nu>
 <57677314.70909@huawei.com>
 <20160620060614.GC1172@leon.nu>
 <5767A004.4060808@huawei.com>
 <20160620092719.GE1172@leon.nu>
 <5767BBDF.6010309@huawei.com>
Reply-To: leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="M9NhX3UHpAaciwkO"
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
In-Reply-To: <5767BBDF.6010309-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 20, 2016 at 05:48:15PM +0800, Wei Hu (Xavier) wrote:
>=20
>=20
> On 2016/6/20 17:27, Leon Romanovsky wrote:
> >On Mon, Jun 20, 2016 at 03:49:24PM +0800, Wei Hu (Xavier) wrote:
> >>
> >>On 2016/6/20 14:06, Leon Romanovsky wrote:
> >>>On Mon, Jun 20, 2016 at 12:37:40PM +0800, Wei Hu (Xavier) wrote:
> >>>>On 2016/6/17 17:58, Leon Romanovsky wrote:
> >>>>>On Thu, Jun 16, 2016 at 10:35:16PM +0800, Lijun Ou wrote:
> >>>>>>This patch mainly added icm support for RoCE. It initializes icm
> >>>>>>which managers the relative memory blocks for RoCE. The data
> >>>>>>structures of RoCE will be located in it. For example, CQ table,
> >>>>>>QP table and MTPT table so on.
> >>>>>>
> >>>>>>Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> >>>>>>Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
> >>>>>>Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> >>>>>>---
> >>>>><...>
> >>>>>
> >>>>>>+
> >>>Another question which you didn't answer [1].
> >>>
> >>>"I wonder if you have the same needs for ICM as it is in mlx4 device.
> >>>Do you have firmware?"
> >>>
> >>>[1] http://marc.info/?l=3Dlinux-rdma&m=3D146545553104913&w=3D2
> >>Hi, Leon
> >>     Now we haven't firmware.
> >>     But hardware still need memory for QPC\CQC\MTPT\mtt etc.
> >ICM stands for InfiniHost (Interconnect) Context Memory is a specific
> >memory place to share between host <-> FW and host <-> HW if HW is
> >aware of specific structures.
> >
> >I assume that in your case, it is enough to allocate memory region and
> >supply it to HW. Am I right?
> For Our hardware,
> 1. ICM has a memory management method, It's very good for QPC\CQC\MTPT\mtt
> etc. we need it.

You need special HW to leverage its. AFAIK it is Mellanox specific.

> 2. The meomry for QPC\CQC\MTPT\mtt only used for RoCE hardware and driver,
> we don't want use MR.

I didn't mean Infiniband MR, but memory region returned from standard
allocation functions (kmalloc, ...).

> 3. Now we haven't firmware, maybe we need it next version.

You are always invited to add support once it will be needed, no need to
add it in advance.

Thanks

--M9NhX3UHpAaciwkO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXZ+nWAAoJEORje4g2clinS94P/0GGhGBG/WNmJyPJSDgPQF5X
jz3r+CYHMi/6LZdSx2cqejzNdNuc2Z8xb4jn1XRl/WxMQEUIQZbFDLS+12Sv+HBT
Z34fpyeyEeqSi/tU/FwcZn83hKluROboOlnbD1nvOjxbrzPICuOi0+EYvJnb2GVo
dia8Gp6i2H1KWLCSD92z+aksbGYQ/5f2nimMX/J07/tXDzs1arcc1YOoJdMkL3yd
JGsGd8IOVu2+TkQBdLlsKl3OMJz5lFaLjfH4xHZKjmLm9WXC3QCPAyOGZHoSDurY
5G6eOxRcj/IHIRt0B+JqxCCyV8ojkqey2hjX7V3xhRNyKQEiLVxaacMpGqF80X14
Qza1q7OiOkU5NqJ1hyB5MriSkgydYRhXyo+S66kP1JMmmcGKYQWfJ0wVKDpumJt3
9uivy6wSTN16GvIlxeMOj7TgbPOdKLhLV5/GAGLcwm5mgR/p5CqUfTZtfoiH8T3A
EjI1dVmJunnPwHqzkWKiZq0PjJknVDIET8/U3sdhJvMVBXzyF53Y+VQNG/YHG5NJ
aEb4ktGc12wjDxpIfWWtnN0OWWctfoNdiW2u3Uzk36WLZA1HGZGVmlGn6K2dzm+y
0++w+//yXJ2FKrMg1xALIefEbo5RcZ98ElZmiVMXHgnTQdyeTXEmzXmHQdeB+Qbh
KdS53oyC86E6Sa2bl4zp
=KFG/
-----END PGP SIGNATURE-----

--M9NhX3UHpAaciwkO--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
