From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 1/3] netdev: introduce new NETIF_F_HW_SWITCH_OFFLOAD feature
 flag for switch device offloads
Date: Thu, 04 Dec 2014 20:17:47 -0800
Message-ID: <548131EB.3060502@cumulusnetworks.com>
References: <1417746401-8140-2-git-send-email-roopa@cumulusnetworks.com> <5481249E.7020902@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: Jianhua Xie <jianhua.xie@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:51227 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933291AbaLEERx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 23:17:53 -0500
In-Reply-To: <5481249E.7020902@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/4/14, 7:21 PM, Jianhua Xie wrote:
>
> =E5=9C=A8 2014=E5=B9=B412=E6=9C=8805=E6=97=A5 10:26, roopa@cumulusnet=
works.com =E5=86=99=E9=81=93:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This is a generic high level feature flag for all switch asic=20
>> features today.
>>
>> switch drivers set this flag on switch ports. Logical devices like
>> bridge, bonds, vxlans can inherit this flag from their slaves/ports.
>>
>> I had to use SWITCH in the name to avoid ambiguity with other featur=
e
>> flags. But, since i have been harping about not calling it 'switch',
>> I am welcome to any suggestions :)
>>
>> An alternative to using a feature flag is to use a IFF_HW_OFFLOAD
>> in net_device_flags.
>> ---
>>   include/linux/netdev_features.h |    2 ++
>>   1 file changed, 2 insertions(+)
>>
>> diff --git a/include/linux/netdev_features.h=20
>> b/include/linux/netdev_features.h
>> index 8e30685..68db1de 100644
>> --- a/include/linux/netdev_features.h
>> +++ b/include/linux/netdev_features.h
>> @@ -66,6 +66,7 @@ enum {
>>       NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN=20
>> STAGs */
>>       NETIF_F_HW_L2FW_DOFFLOAD_BIT,    /* Allow L2 Forwarding in=20
>> Hardware */
>>       NETIF_F_BUSY_POLL_BIT,        /* Busy poll */
>> +    NETIF_F_HW_SWITCH_OFFLOAD_BIT,  /* HW switch offload */
> I am interested in this flag very much, but I am not very clear
> how many offload capabilities does this flag imply.  If this flag
> belongs to a general flag and can be accepted by all vendors,
> I will reuse this flag to introduce another out going data traffics
> distribution offload method to bonding driver.
Right now its a one global offload flag for switch asics. Some may not=20
want to tune it more. But others may and so i do expect more flags in=20
this category.

Thanks,
Roopa
