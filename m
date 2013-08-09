From: Kumar Gaurav <kumargauravgupta3@gmail.com>
Subject: Re: [PATCH 17/17] net:ethernet:lantiq_etop.c: Removed deprecated
 IRQF_DISABLED
Date: Sat, 10 Aug 2013 01:30:09 +0530
Message-ID: <52054A49.6000008@gmail.com>
References: <1376072759-11814-1-git-send-email-kumargauravgupta3@gmail.com> <52054527.8080907@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, gregkh@linuxfoundation.org,
	yongjun_wei@trendmicro.com.cn, konszert@marvell.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52054527.8080907@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 10 August 2013 01:08 AM, Sergei Shtylyov wrote:
> Hello.
>
> On 08/09/2013 10:25 PM, Kumar Gaurav wrote:
>
>> Removed IRQF_DISABLED as it is deprecated and fixed a coding style issue
>> of more than 80 chars on single line by sliting the line in two.
>
>    That's clearly a material for 2 separate patches.
>
>> Signed-off-by: Kumar Gaurav <kumargauravgupta3@gmail.com>
>> ---
>>   drivers/net/ethernet/lantiq_etop.c |    8 +++++---
>>   1 file changed, 5 insertions(+), 3 deletions(-)
>
>> diff --git a/drivers/net/ethernet/lantiq_etop.c 
>> b/drivers/net/ethernet/lantiq_etop.c
>> index bfdb0686..04c3a82 100644
>> --- a/drivers/net/ethernet/lantiq_etop.c
>> +++ b/drivers/net/ethernet/lantiq_etop.c
> [...]
>> @@ -653,7 +653,9 @@ ltq_etop_init(struct net_device *dev)
>>       if (err)
>>           goto err_netdev;
>>
>> -    /* Set addr_assign_type here, ltq_etop_set_mac_address would 
>> reset it. */
>> +    /* Set addr_assign_type here,
>> +     *ltq_etop_set_mac_address would reset it.
>
>    You forgot space after * here.
>
> WBR, Sergei
>
Okay i'll be sending them in separate and correcting a space issue as told.
thanks

Regards
Kumar Gaurav
