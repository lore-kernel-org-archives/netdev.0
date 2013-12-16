From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net-next] sch_tbf: add TBF_BURST/TBF_PBURST attribute
Date: Mon, 16 Dec 2013 10:11:59 +0800
Message-ID: <52AE616F.9050001@huawei.com>
References: <1386927716-7896-1-git-send-email-yangyingliang@huawei.com> <52AAD867.5030305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:36025 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461Ab3LPCMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 21:12:14 -0500
In-Reply-To: <52AAD867.5030305@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/13 17:50, Duan Jiong wrote:
> =E4=BA=8E 2013=E5=B9=B412=E6=9C=8813=E6=97=A5 17:41, Yang Yingliang =E5=
=86=99=E9=81=93:
>> When we set burst to 1514 with low rate in userspace,
>> the kernel get a value of burst that less than 1514,
>> which doesn't work.
>>
>> Because it may make some loss when transform burst
>> to buffer in userspace. This makes burst lose some
>> bytes, when the kernel transform the buffer back to
>> burst.
>>
>> This patch adds two new attributes to support sending
>> burst/mtu to kernel directly to avoid the loss.
>>
>> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
>> ---
[...]
>> diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
>> index 887e672..a746049 100644
>> --- a/net/sched/sch_tbf.c
>> +++ b/net/sched/sch_tbf.c
>> @@ -307,6 +307,8 @@ static const struct nla_policy tbf_policy[TCA_TB=
=46_MAX + 1] =3D {
>>  	[TCA_TBF_PTAB]	=3D { .type =3D NLA_BINARY, .len =3D TC_RTAB_SIZE }=
,
>>  	[TCA_TBF_RATE64]	=3D { .type =3D NLA_U64 },
>>  	[TCA_TBF_PRATE64]	=3D { .type =3D NLA_U64 },
>> +	[TCA_TBF_BURST]		=3D { .type =3D NLA_U32 },
>=20
> This place should remove one tab.
>=20
> Thanks,
>   Duan
>=20

OK, thanks!
