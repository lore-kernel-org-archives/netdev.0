From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH net-next 2/6] ethernet: wiznet: remove unnecessary check
Date: Wed, 22 Oct 2014 17:54:19 +0530
Message-ID: <5447A1F3.2080206@gmail.com>
References: <N> <1413951386-29645-1-git-send-email-varkab@cdac.in> <1413951386-29645-3-git-send-email-varkab@cdac.in> <544798AE.1040209@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Varka Bhadram <varkab@cdac.in>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:43246 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933003AbaJVM1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 08:27:13 -0400
Received: by mail-pd0-f177.google.com with SMTP id g10so1384076pdj.22
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 05:27:13 -0700 (PDT)
In-Reply-To: <544798AE.1040209@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/2014 05:14 PM, Sergei Shtylyov wrote:
> On 10/22/2014 8:16 AM, Varka Bhadram wrote:
>
>> devm_ioremap_resource checks platform_get_resource() return value.
>> We can remove the duplicate check here.
>
>> Signed-off-by: Varka Bhadram <varkab@cdac.in>
>> ---
>>   drivers/net/ethernet/wiznet/w5300.c |    3 +--
>>   1 file changed, 1 insertion(+), 2 deletions(-)
>
>> diff --git a/drivers/net/ethernet/wiznet/w5300.c 
>> b/drivers/net/ethernet/wiznet/w5300.c
>> index f961f14..315d090 100644
>> --- a/drivers/net/ethernet/wiznet/w5300.c
>> +++ b/drivers/net/ethernet/wiznet/w5300.c
>> @@ -558,8 +558,7 @@ static int w5300_hw_probe(struct platform_device 
>> *pdev)
>>       }
>>
>>       mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>> -    if (!mem)
>> -        return -ENXIO;
>> +
>>       mem_size = resource_size(mem);
>
>    Same problem as in the patch #1
>
I will fix it . Thanks

>>
>>       priv->base = devm_ioremap_resource(&pdev->dev, mem);
>>
>
> WBR, Sergei
>


-- 
Regards,
Varka Bhadram.
