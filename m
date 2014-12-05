From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 3/3] rocker: set feature NETIF_F_HW_SWITCH_OFFLOAD
Date: Fri, 05 Dec 2014 06:04:13 -0800
Message-ID: <5481BB5D.6070409@cumulusnetworks.com>
References: <1417746401-8140-4-git-send-email-roopa@cumulusnetworks.com> <5481B0A2.9070109@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:34545 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbaLEOE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 09:04:26 -0500
In-Reply-To: <5481B0A2.9070109@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ack, will fix them.

On 12/5/14, 5:18 AM, Sergei Shtylyov wrote:
> Hello.
>
> On 12/5/2014 5:26 AM, roopa@cumulusnetworks.com wrote:
>
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>> This patch just sets the feature flag on rocker ports
>
>    You didn't sign off on any of your patches, hence they can't be 
> applied.
>
>> ---
>>   drivers/net/ethernet/rocker/rocker.c |    3 ++-
>>   1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/rocker/rocker.c 
>> b/drivers/net/ethernet/rocker/rocker.c
>> index fded127..3fe19b0 100644
>> --- a/drivers/net/ethernet/rocker/rocker.c
>> +++ b/drivers/net/ethernet/rocker/rocker.c
>> @@ -4003,7 +4003,8 @@ static int rocker_probe_port(struct rocker 
>> *rocker, unsigned int port_number)
>>                  NAPI_POLL_WEIGHT);
>>       rocker_carrier_init(rocker_port);
>>
>> -    dev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
>> +    dev->features |= NETIF_F_HW_VLAN_CTAG_FILTER |
>> +                     NETIF_F_HW_SWITCH_OFFLOAD;
>
>    There was no need tho break the line.
>
> [...]
>
> WBR, Sergei
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
