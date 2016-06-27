From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v10 03/22] IB/hns: Add initial main frame driver and get
 cfg info
Date: Mon, 27 Jun 2016 10:00:54 +0300
Message-ID: <20160627070054.GK23995@leon.nu>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-4-git-send-email-oulijun@huawei.com>
 <20160624114831.GD23995@leon.nu>
 <576E5D0B.7010003@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5mZBmBd1ZkdwT1ny"
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
In-Reply-To: <576E5D0B.7010003-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--5mZBmBd1ZkdwT1ny
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jun 25, 2016 at 06:29:31PM +0800, Wei Hu (Xavier) wrote:
>=20
>=20
> On 2016/6/24 19:48, Leon Romanovsky wrote:
> >On Thu, Jun 16, 2016 at 10:35:11PM +0800, Lijun Ou wrote:
> >>This patch mainly added the initial bare main driver. It
> >>could get the relative configure information of net node.
> >>
> >>Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> >>Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
> >>Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> >>---

=2E..

> >>+		return -ENOMEM;
> >>+
> >>+	for (i =3D 0; i < HNS_ROCE_MAX_PORTS; i++) {
> >>+		net_node =3D of_parse_phandle(np, "eth-handle", i);
> >>+		if (net_node) {
> >>+			pdev =3D of_find_device_by_node(net_node);
> >>+			netdev =3D platform_get_drvdata(pdev);
> >>+			phy_port =3D (u8)i;
> >>+			if (netdev) {
> >>+				hr_dev->iboe.netdevs[port_cnt] =3D netdev;
> >>+				hr_dev->iboe.phy_port[port_cnt] =3D phy_port;
> >>+			} else {
> >>+				return -ENODEV;
> >>+			}
> >>+			port_cnt++;
> >>+		}
> >>+	}
> >Do you want to check port_cnt value, before continue?
> Hi, Leon
>     Maybe we need not to check port_cnt value.
>     port_cnt can be ensured smaller than HNS_ROCE_MAX_PORTS.

You can in theory to get port_cnt =3D=3D 0, in such case it is wise to
return error.


--5mZBmBd1ZkdwT1ny
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXcM8mAAoJEORje4g2clino0YP/A9Jw0Hi5NcGGj6XS7oG2OtF
fFI9wnHfQW8ZAEbfiPDxovxKmT/5BparU/IJk/WX5qVO3iQoVkQx4HsoNnsmtlQB
lGUpdL/Epd++BXi4jT8FD77GpMO4gzGMK4apiK66lvji40vxnguhD7Dtv8k3RM1C
jnaHpl5OKj2L/2X935vMasbZQJSQzMtt0yRK/7E4PCnvL1XgMXevf1xfVi85V/Un
DSSgh3Mep8znezVxWuqTbrBG2pbKGWXUD5wngLoQ2EDHh31jC4sIdEzV2bb726l1
zHq7Ix+ELgk4/jpX5tCP0MILqIOdcsOKiUYgUP7p44/mefGLMaZtOVrhlkUYhXkD
f5dyPanVxO9UMbexDO1qdxLUHF/LQqiCotcll44hftm/U3CzSNkAN/npKt6OwaVN
aiGXgQdh2DfBx/1/jj0jO55UdUCvR321Cv+LxUYDqXDJ8nEk3JgUA0/VK7qW+5cA
4s+ysQaHsHj0IBF6FiWZp4kYLmhrTdm13iS7DnTnK2QKHcSqmRwQRwRwJOW/D8j+
/h1oqVsntAhqqnb0WfAaWfUtAgNcN2bg1jg1GPooYkiJxDPDJQZ+evbF6bLqe7qz
MqWMMeYt88C5CJMyHmUaaAi1BdWIFoomkeJIkF6Iu0mGU7tuoNJH7A87O5Loh0MQ
OwZNZ/8/pYekxSi0zrU0
=JQam
-----END PGP SIGNATURE-----

--5mZBmBd1ZkdwT1ny--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
