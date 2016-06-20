From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v10 08/22] IB/hns: Add icm support
Date: Mon, 20 Jun 2016 12:27:19 +0300
Message-ID: <20160620092719.GE1172@leon.nu>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-9-git-send-email-oulijun@huawei.com>
 <20160617095834.GA5408@leon.nu>
 <57677314.70909@huawei.com>
 <20160620060614.GC1172@leon.nu>
 <5767A004.4060808@huawei.com>
Reply-To: leon@kernel.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="6e7ZaeXHKrTJCxdu"
Cc: Lijun Ou <oulijun@huawei.com>, dledford@redhat.com,
	sean.hefty@intel.com, hal.rosenstock@gmail.com,
	davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jiri@mellanox.com, ogerlitz@mellanox.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, gongyangming@huawei.com,
	xiaokun@huawei.com, tangchaofei@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, yankejian@huawei.com,
	charles.chenxin@huawei.com, linuxarm@huawei.com
To: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5767A004.4060808@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--6e7ZaeXHKrTJCxdu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 20, 2016 at 03:49:24PM +0800, Wei Hu (Xavier) wrote:
>=20
>=20
> On 2016/6/20 14:06, Leon Romanovsky wrote:
> >On Mon, Jun 20, 2016 at 12:37:40PM +0800, Wei Hu (Xavier) wrote:
> >>
> >>On 2016/6/17 17:58, Leon Romanovsky wrote:
> >>>On Thu, Jun 16, 2016 at 10:35:16PM +0800, Lijun Ou wrote:
> >>>>This patch mainly added icm support for RoCE. It initializes icm
> >>>>which managers the relative memory blocks for RoCE. The data
> >>>>structures of RoCE will be located in it. For example, CQ table,
> >>>>QP table and MTPT table so on.
> >>>>
> >>>>Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
> >>>>Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
> >>>>Signed-off-by: Lijun Ou <oulijun@huawei.com>
> >>>>---
> >>><...>
> >>>
> >>>>+
> >Another question which you didn't answer [1].
> >
> >"I wonder if you have the same needs for ICM as it is in mlx4 device.
> >Do you have firmware?"
> >
> >[1] http://marc.info/?l=3Dlinux-rdma&m=3D146545553104913&w=3D2
> Hi, Leon
>     Now we haven't firmware.
>     But hardware still need memory for QPC\CQC\MTPT\mtt etc.

ICM stands for InfiniHost (Interconnect) Context Memory is a specific
memory place to share between host <-> FW and host <-> HW if HW is
aware of specific structures.

I assume that in your case, it is enough to allocate memory region and
supply it to HW. Am I right?

>=20
> Thanks
> Wei Hu
> >>Regards
> >>Wei Hu
> >>
>=20
>=20

--6e7ZaeXHKrTJCxdu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXZ7b3AAoJEORje4g2clincEoQAI+ddKVx36/HBsHieA0QGvIR
dyscLKRyeqn6i6NQ5I2KrOEWizX/d2euYLeTlBo/O+PWqN48t40G6WwZq6uwENo9
boufluvoO8ppSGaah/d4SN8+q+h7mmrgQMIQFEYY7HCSUsrnrQjV3OjY7T9Dkx/+
ZA60s9asATlDG3dKjnkAlrWV+psh9F9UgqTjystyoun/VFyx4ZzMegkaslLt+R+q
LIpXv/FhJxMP4CVmi3PsTT2FYmPd1G4pLNnwYGAVXlRo5Exkavjk19I72JClE+IQ
8rNZLfBxENkjAWqz6TDzy0MPWI+xj+3tKsZC5G3vZGe2LXQo3jSqjoWSZCw72Mbk
CQvWky8PF3sP6EyHwsbtoRHXUAfJ50V4FlrAbHkE5oHvBU0VWJIWGLUfO0KdWj0w
gKPA2gg5lDKhFfxg8gF+Bvc4zoPEekMsFP+fMYkrAIK9nSMQkbtzIFI/Piijsb94
/wi3rWwvw5ecffZPVchLpyYgjxadckKYOfnOuCgpQq819t4KjIEJ37U8uUuKMxxP
2Pn/FCGIrzYB6/0znvFzJaL8s/IaTC6ftTJDgMM5+zReQvzKs7atYFcXL7x84Qe4
DMrzV7GSlHFQeRjGDG5yZSTFeRQdy67uhpfS2cdVV4Sk9T7iDBrec0wNT9CQnr6q
R4J1VcFmKmhyyWoD0FWS
=UXpm
-----END PGP SIGNATURE-----

--6e7ZaeXHKrTJCxdu--
