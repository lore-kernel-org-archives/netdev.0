From: Yisen Zhuang <Yisen.zhuang@huawei.com>
Subject: Re: [PATCH net 06/10] net: hns: fix return value of the function
 about rss
Date: Tue, 22 Mar 2016 09:16:29 +0800
Message-ID: <56F09CED.3060607@huawei.com>
References: <1458558401-190165-1-git-send-email-Yisen.Zhuang@huawei.com>
 <1458558401-190165-7-git-send-email-Yisen.Zhuang@huawei.com>
 <20160321.114238.1469581550499984000.davem@davemloft.net>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:24862 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758026AbcCVBR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 21:17:27 -0400
In-Reply-To: <20160321.114238.1469581550499984000.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



=E5=9C=A8 2016/3/21 23:42, David Miller =E5=86=99=E9=81=93:
> From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
> Date: Mon, 21 Mar 2016 19:06:37 +0800
>=20
>> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/driv=
ers/net/ethernet/hisilicon/hns/hns_ethtool.c
>> index 3c4a3bc..f3a5e05 100644
>> --- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
>> +++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
>  ...
>> @@ -1235,12 +1226,11 @@ hns_set_rss(struct net_device *netdev, const=
 u32 *indir, const u8 *key,
>>  {
>>  	struct hns_nic_priv *priv =3D netdev_priv(netdev);
>>  	struct hnae_ae_ops *ops;
>> -	int ret;
>> =20
>>  	if (AE_IS_VER1(priv->enet_ver)) {
>>  		netdev_err(netdev,
>>  			   "RSS feature is not supported on this hardware\n");
>> -		return -EOPNOTSUPP;
>> +		return (u32)-EOPNOTSUPP;
>>  	}
>> =20
>=20
> This is incredibly broken, you cannot cast this negative error return=
 value to
> an unsigned integer.
>=20
Hi David,

This is my misunderstanding of the return value. Will fix it in next ve=
rsion.

Many thanks,

Yisen

> .
>=20
