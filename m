From: Yisen Zhuang <Yisen.zhuang@huawei.com>
Subject: Re: [PATCH net 03/10] net: hns: add uc match for debug ports
Date: Tue, 22 Mar 2016 09:03:12 +0800
Message-ID: <56F099D0.3070102@huawei.com>
References: <1458558401-190165-1-git-send-email-Yisen.Zhuang@huawei.com>
 <1458558401-190165-4-git-send-email-Yisen.Zhuang@huawei.com>
 <20160321.114055.845640249977716034.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <yankejian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <lisheng011@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>, <arnd@arndb.de>,
	<xieqianqian@huawei.com>, <andrew@lunn.ch>, <ivecera@redhat.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linuxarm@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160321.114055.845640249977716034.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



=E5=9C=A8 2016/3/21 23:40, David Miller =E5=86=99=E9=81=93:
> From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
> Date: Mon, 21 Mar 2016 19:06:34 +0800
>=20
>> +	(void)hns_mac_set_promisc(mac_cb, (u8)!!en);
>=20
> This cast to void is unnecssary.

I think hns_mac_set_promisc don't need to return a value=EF=BC=8C so i =
will fix it in next submit.

Thanks

>=20
>> +static void hns_gmac_set_uc_match(void *mac_drv, u16 en)
>> +{
>> +	struct mac_driver *drv =3D (struct mac_driver *)mac_drv;
>=20
> Casts from void pointers are unnecessary.

Will fix it in next submit.

Thanks

>=20
>> +{
>> +	struct mac_driver *drv =3D (struct mac_driver *)mac_drv;
>=20
> Likewise.

Will fix it in next submit.

Thanks,

Yisen

>=20
> .
>=20
