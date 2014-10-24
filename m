From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH net-next v2 5/6] ethernet: renesas: remove unnecessary
 check
Date: Fri, 24 Oct 2014 07:45:11 +0530
Message-ID: <5449B62F.4020002@gmail.com>
References: <1414029531-5067-1-git-send-email-varkab@cdac.in> <1414029531-5067-6-git-send-email-varkab@cdac.in> <5448F4AE.1080901@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:65422 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078AbaJXCPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 22:15:41 -0400
Received: by mail-pd0-f177.google.com with SMTP id v10so562964pde.22
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 19:15:41 -0700 (PDT)
In-Reply-To: <5448F4AE.1080901@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 23 October 2014 05:59 PM, Sergei Shtylyov wrote:
> On 10/23/2014 5:58 AM, Varka Bhadram wrote:
>
>> devm_ioremap_resource checks platform_get_resource() return value.
>> We can remove the duplicate check here.
>
>> Signed-off-by: Varka Bhadram <varkab@cdac.in>
>> ---
>>   drivers/net/ethernet/renesas/sh_eth.c |    9 +++------
>>   1 file changed, 3 insertions(+), 6 deletions(-)
>
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c 
>> b/drivers/net/ethernet/renesas/sh_eth.c
>> index 60e9c2c..ffb49f3 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> [...]
>> @@ -2781,8 +2777,6 @@ static int sh_eth_drv_probe(struct 
>> platform_device *pdev)
>>       pm_runtime_enable(&pdev->dev);
>>       pm_runtime_get_sync(&pdev->dev);
>>
>> -    /* The sh Ether-specific entries in the device structure. */
>> -    ndev->base_addr = res->start;
>>       devno = pdev->id;
>>       if (devno < 0)
>>           devno = 0;
>> @@ -2806,6 +2800,9 @@ static int sh_eth_drv_probe(struct 
>> platform_device *pdev)
>>           goto out_release;
>>       }
>>
>> +    /* The sh Ether-specific entries in the device structure. */
>
>    No need to move the comment, at least not there.
>
>> +    ndev->base_addr = res->start;
>> +
>>       spin_lock_init(&mdp->lock);
>>       mdp->pdev = pdev;
>
> WBR, Sergei
>
thanks for the review. In v3 i will address these issues.

-- 
Thanks and Regards,
Varka Bhadram.
