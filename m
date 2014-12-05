From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 3/3] rocker: set feature NETIF_F_HW_SWITCH_OFFLOAD
Date: Thu, 04 Dec 2014 20:14:37 -0800
Message-ID: <5481312D.6080708@cumulusnetworks.com>
References: <1417746401-8140-4-git-send-email-roopa@cumulusnetworks.com> <5481259C.3040707@freescale.com>
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
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:51036 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933462AbaLEEOo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 23:14:44 -0500
In-Reply-To: <5481259C.3040707@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/4/14, 7:25 PM, Jianhua Xie wrote:
>
> =E5=9C=A8 2014=E5=B9=B412=E6=9C=8805=E6=97=A5 10:26, roopa@cumulusnet=
works.com =E5=86=99=E9=81=93:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch just sets the feature flag on rocker ports
>> ---
>>   drivers/net/ethernet/rocker/rocker.c |    3 ++-
>>   1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/rocker/rocker.c=20
>> b/drivers/net/ethernet/rocker/rocker.c
>> index fded127..3fe19b0 100644
>> --- a/drivers/net/ethernet/rocker/rocker.c
>> +++ b/drivers/net/ethernet/rocker/rocker.c
>> @@ -4003,7 +4003,8 @@ static int rocker_probe_port(struct rocker=20
>> *rocker, unsigned int port_number)
>>                  NAPI_POLL_WEIGHT);
>>       rocker_carrier_init(rocker_port);
>>   -    dev->features |=3D NETIF_F_HW_VLAN_CTAG_FILTER;
>> +    dev->features |=3D NETIF_F_HW_VLAN_CTAG_FILTER |
>> +                     NETIF_F_HW_SWITCH_OFFLOAD;
> Do you have a plan on enabling/disabling  this flag dynamically by=20
> ethtool?

I have not thought about it yet. But if this gets accepted, then yes, I=
=20
will have an ethtool way for drivers who want it.
if we have a IFF_ flag for this (which is also one of my alternate=20
proposals), there will be a netlink way to set it on and off.
