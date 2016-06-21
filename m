From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v10 06/22] IB/hns: Add initial cmd operation
Date: Tue, 21 Jun 2016 14:28:08 +0300
Message-ID: <20160621112808.GA9762@leon.nu>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-7-git-send-email-oulijun@huawei.com>
 <20160620133310.GB4526@leon.nu>
 <57691C0B.8090509@huawei.com>
Reply-To: leon@kernel.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="sm4nu43k4a2Rpi4c"
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
In-Reply-To: <57691C0B.8090509@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--sm4nu43k4a2Rpi4c
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jun 21, 2016 at 06:50:51PM +0800, Wei Hu (Xavier) wrote:
>=20
>=20
> On 2016/6/20 21:33, Leon Romanovsky wrote:
> >On Thu, Jun 16, 2016 at 10:35:14PM +0800, Lijun Ou wrote:
> >>This patch added the operation for cmd, and added some functions
> >>for initializing eq table and selecting cmd mode.
> >>
> >>Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
> >>Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
> >>Signed-off-by: Lijun Ou <oulijun@huawei.com>
> >>---
> >>PATCH v9/v8/v7/v6:
> >>- No change over the PATCH v5
> >>
> >>PATCH v5:
> >>- The initial patch which was redesigned based on the second patch
> >>   in PATCH v4
> >>---
> ><...>
> >
> >>+#define CMD_MAX_NUM		32
> >>+
> >>+int hns_roce_cmd_init(struct hns_roce_dev *hr_dev)
> >>+{
> >>+	struct device *dev =3D &hr_dev->pdev->dev;
> >>+
> >>+	mutex_init(&hr_dev->cmd.hcr_mutex);
> >>+	sema_init(&hr_dev->cmd.poll_sem, 1);
> >>+	hr_dev->cmd.use_events =3D 0;
> >>+	hr_dev->cmd.toggle =3D 1;
> >>+	hr_dev->cmd.max_cmds =3D CMD_MAX_NUM;
> ><...>
> >
> >>+	for (hr_cmd->token_mask =3D 1; hr_cmd->token_mask < hr_cmd->max_cmds;
> >>+	     hr_cmd->token_mask <<=3D 1)
> >>+		;
> >>+	--hr_cmd->token_mask;
> >It doesn't look that you dynamically change max_cmds supported.
> >Why do you need to calculate token_mask dynamically?
> Hi, Leon
>=20
>     1. The four lines above are in the function named
> hns_roce_cmd_use_events.
>          and now this function is only called once in hns_roce_probe.
>     2. In hns_roce_cmd_use_events,
>         we use these 4 lines to achieve the value of hr_cmd->token_mask
> according to hr_cmd->max_cmds dynamically,
>         then we only define one marco for hr_cmd->max_cmds as below:
>=20
> 	#define CMD_MAX_NUM		32
>=20
>        And it looks more flexible.

It is called over engineering.
I would recommend to you to remove it.

We don't need over complicated code which is executed
once with need to maintain with zero benefit.

The other places need such simplification too.

>=20
> Regards
> Wei Hu
>=20
>=20
>=20

--sm4nu43k4a2Rpi4c
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXaSTIAAoJEORje4g2clin7YUQAKabdqigIu7Q/La+NL2cTXj/
xgt+xQH9CBURQVV/nrwa3Kwrr4xyEenvh8iDdCRllNFylNKy8BH/3Lsc5tQnCLB0
KcHJNjIOI1Y2RxiAH3UPWl2eDwRG1ShIapYRNwNP9wsSDQyKWdeIHqGZxikYCI8l
NMeOE1OT6JAi3P1Fiivwf/65wS/kWSrlKDKt9TcaaQyZLvzgmT5RMSc/LWQ0LFES
LaW6WuFQnYPM3MCmMM8Er2lbHpNGo56Rx4XfnO9mmspsprztknV5TQ72kvUBaqUe
BoqfpeDbOVag3zP51mjskne5uS1cc/u4ebOBi0ZsJnbq6zqOhMhjXQ78joLWhr75
xAYcBm+trfoyzQ5FHzmY01d+ApjwZ0A0RUnmqtrrQpsn+fY+L8awjvjGBqhof1Zm
It6R1NNpjam5Jj+cSZZwuWXOq/t01rcJC3Vsi74ubD6s5Nsl1i9O4X+HYlFpIDmO
cx/+MCoQsjhW1GIq+3SUL6zTDnfGN55uVaM98lDny8xzmmnQmuYmMMW8182MyrIO
TETalodiILdySDaoqDuZVcGXgFsZCG3LFsa5NonpVlf04OthUpzl6xDunKPFj/uF
nnZPq+vCNopVPtytadEnwndCn2h5LnHfhHXaSSgTQV8E2EmMHVno4P9zP+12+ve4
IOj84IzyH25CQ8aMg109
=EUWe
-----END PGP SIGNATURE-----

--sm4nu43k4a2Rpi4c--
