From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: Re: [PATCH 18/19] drivers/net/ethernet/marvell: add missing platform_driver
 owne
Date: Wed, 22 May 2013 09:06:45 +0800
Message-ID: <519C1A25.8020107@huawei.com>
References: <1369104171-8824-1-git-send-email-libo.chen@huawei.com> <519B728F.2000905@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Libo Chen <libo.chen@huawei.com>,
	<thomas.petazzoni@free-electrons.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<lizefan@huawei.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:4725 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850Ab3EVBHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 21:07:47 -0400
In-Reply-To: <519B728F.2000905@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/5/21 21:11, Sergei Shtylyov wrote:
> Hello.
> 
> On 21-05-2013 6:42, Libo Chen wrote:
> 
>> set the owner of platform_driver, to ensure that the
>> caller of driver holds a module refernece
> 
>> Signed-off-by: Libo Chen <libo.chen@huawei.com>
>> ---
>>   drivers/net/ethernet/marvell/mvneta.c |    1 +
>>   1 files changed, 1 insertions(+), 0 deletions(-)
> 
>> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
>> index c966785..be35a3e 100644
>> --- a/drivers/net/ethernet/marvell/mvneta.c
>> +++ b/drivers/net/ethernet/marvell/mvneta.c
>> @@ -2820,6 +2820,7 @@ static struct platform_driver mvneta_driver = {
>>       .remove = mvneta_remove,
>>       .driver = {
>>           .name = MVNETA_DRIVER_NAME,
>> +        .owner    = THIS_MODULE,
> 
>    Indent this = with space or indent all ='s with tabs.


thanks for your suggest.

Regards,

Libo
> 
>>           .of_match_table = mvneta_match,
>>       },
>>   };
> 
> WBR, Sergei
> 
> 
> 
> 
