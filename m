From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH net-next 5/6] ethernet: renesas: remove unnecessary check
Date: Wed, 22 Oct 2014 17:52:28 +0530
Message-ID: <5447A184.6080505@gmail.com>
References: <N> <1413951386-29645-1-git-send-email-varkab@cdac.in> <1413951386-29645-6-git-send-email-varkab@cdac.in> <5447995F.5080602@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Varka Bhadram <varkab@cdac.in>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:63242 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933172AbaJVMZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 08:25:27 -0400
Received: by mail-pd0-f182.google.com with SMTP id y10so3446519pdj.13
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 05:25:27 -0700 (PDT)
In-Reply-To: <5447995F.5080602@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/2014 05:17 PM, Sergei Shtylyov wrote:
> On 10/22/2014 8:16 AM, Varka Bhadram wrote:
>
>> devm_ioremap_resource checks platform_get_resource() return value.
>> We can remove the duplicate check here.
>
>> Signed-off-by: Varka Bhadram <varkab@cdac.in>
>> ---
>>   drivers/net/ethernet/renesas/sh_eth.c |    4 ----
>>   1 file changed, 4 deletions(-)
>
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c 
>> b/drivers/net/ethernet/renesas/sh_eth.c
>> index 60e9c2c..d824ba5 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
>> @@ -2769,10 +2769,6 @@ static int sh_eth_drv_probe(struct 
>> platform_device *pdev)
>>
>>       /* get base addr */
>>       res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>> -    if (unlikely(res == NULL)) {
>> -        dev_err(&pdev->dev, "invalid resource\n");
>> -        return -EINVAL;
>> -    }
>
>    The driver dereferences 'res' further on, so you can't remove this 
> check.
>
Yes its my mistake . I will fix it . Thankx

> WBR, Sergei
>
-- 
Regards,
Varka Bhadram.
