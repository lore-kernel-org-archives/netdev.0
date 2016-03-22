From: Yisen Zhuang <Yisen.zhuang@huawei.com>
Subject: Re: [PATCH net 01/10] net: hns: bug fix about ping6
Date: Tue, 22 Mar 2016 08:46:10 +0800
Message-ID: <56F095D2.70604@huawei.com>
References: <1458558401-190165-1-git-send-email-Yisen.Zhuang@huawei.com>
 <1458558401-190165-2-git-send-email-Yisen.Zhuang@huawei.com>
 <20160321.113924.1745428836278929494.davem@davemloft.net>
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
In-Reply-To: <20160321.113924.1745428836278929494.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



=E5=9C=A8 2016/3/21 23:39, David Miller =E5=86=99=E9=81=93:
> From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
> Date: Mon, 21 Mar 2016 19:06:32 +0800
>=20
>> From: Kejian Yan <yankejian@huawei.com>
>>
>> The current upstreaming code fails to ping other IPv6 net device, be=
cause
>> the enet receives the multicast packets with the src mac addr whick =
is the
>                                                                 ^^^^^
>=20
> "which"

Will fix it in next submit.

Thanks

>=20
>> @@ -670,6 +671,14 @@ out_bnum_err:
>>  		return -EFAULT;
>>  	}
>> =20
>> +	/* filter out multicast pkt with the same src mac as this port */
>> +	eh =3D (struct ethhdr *)skb->data;
>=20
> Please use the "eth_hdr()" helper.

Will fix it in next submit.

Thanks,

Yisen

>=20
> .
>=20
