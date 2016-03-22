From: Yisen Zhuang <Yisen.zhuang@huawei.com>
Subject: Re: [PATCH net 09/10] net: hns: adds limitation for debug port mtu
Date: Tue, 22 Mar 2016 09:19:52 +0800
Message-ID: <56F09DB8.5010908@huawei.com>
References: <1458558401-190165-1-git-send-email-Yisen.Zhuang@huawei.com>
 <1458558401-190165-10-git-send-email-Yisen.Zhuang@huawei.com>
 <56F0028D.4070500@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <yankejian@huawei.com>,
	<huangdaode@hisilicon.com>, <salil.mehta@huawei.com>,
	<lisheng011@huawei.com>, <lipeng321@huawei.com>,
	<liguozhu@huawei.com>, <arnd@arndb.de>, <xieqianqian@huawei.com>,
	<andrew@lunn.ch>, <ivecera@redhat.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:26456 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbcCVBUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 21:20:42 -0400
In-Reply-To: <56F0028D.4070500@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



=E5=9C=A8 2016/3/21 22:17, Sergei Shtylyov =E5=86=99=E9=81=93:
> Hello.
>=20
> On 03/21/2016 02:06 PM, Yisen Zhuang wrote:
>=20
>> From: Kejian Yan <yankejian@huawei.com>
>>
>> If mtu for debug port is set more than 1500, it may cause that packe=
ts
>> are dropped by ppe. So maximum value for debug port should be 1500.
>>
>> Signed-off-by: Kejian Yan <yankejian@huawei.com>
>> Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
> [...]
>> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/dri=
vers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
>> index a69c8af..a68efd6 100644
>> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
>> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
>> @@ -28,6 +28,7 @@ struct dsaf_device;
>>   #define MAC_MAX_MTU        9600
>>   #define MAC_MAX_MTU_V2        9728
>>   #define MAC_MIN_MTU        68
>> +#define MAC_MAX_MTU_DBG         MAC_DEFAULT_MTU
>=20
>    Please use tabs, not spaces to indent the value, like above

Will fix it in next version.

Thanks,

Yisen

>=20
> [...]
>=20
> MBR, Sergei
>=20
>=20
> .
>=20
