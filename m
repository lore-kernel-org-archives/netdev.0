From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 3/6] net: hns: fixed portid bug in sending manage pkt
Date: Fri, 11 Mar 2016 16:29:29 +0300
Message-ID: <56E2C839.4000700@cogentembedded.com>
References: <1457053798-93513-1-git-send-email-huangdaode@hisilicon.com>
 <1457053798-93513-4-git-send-email-huangdaode@hisilicon.com>
 <56D98F8F.5010700@cogentembedded.com> <56E2251D.905@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, linuxarm@huawei.com,
	salil.mehta@huawei.com, kenneth-lee-2012@foxmail.com,
	xuwei5@hisilicon.com, lisheng011@huawei.com, yankejian@huawei.com
To: Daode Huang <huangdaode@hisilicon.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:33183 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752878AbcCKN3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 08:29:35 -0500
Received: by mail-lb0-f176.google.com with SMTP id k15so156960438lbg.0
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 05:29:34 -0800 (PST)
In-Reply-To: <56E2251D.905@hisilicon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/11/2016 4:53 AM, Daode Huang wrote:

>>> In V2 chip, when sending mamagement packets, the driver should
>>> config the port id to BD descs.
>>>
>>> Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
>>> Signed-off-by: Lisheng <lisheng011@huawei.com>
>>> ---
>>>   drivers/net/ethernet/hisilicon/hns/hnae.h         | 3 +++
>>>   drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c | 1 +
>>>   drivers/net/ethernet/hisilicon/hns/hns_enet.c     | 4 ++++
>>>   3 files changed, 8 insertions(+)
>>>
>>> diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h
>>> b/drivers/net/ethernet/hisilicon/hns/hnae.h
>>> index 1cbcb9f..11a3f97 100644
>>> --- a/drivers/net/ethernet/hisilicon/hns/hnae.h
>>> +++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
>> [...]
>>> @@ -516,6 +518,7 @@ struct hnae_handle {
>>>       int q_num;
>>>       int vf_id;
>>>       u32 eport_id;
>>> +    u32 dport_id;    /*v2 tx bd should fill the dport_id*/
>>
>>    Please add spaces after /* and before */ (like it's done in other places
>> in this driver).
>>
>
> Hi MBR, Sergei,

    Just in case: MBR stands for "my best regards", Sergei is my name. :-)

> Daode.

MBR, Sergei
