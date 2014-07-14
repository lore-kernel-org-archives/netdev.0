From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH net-next v2 3/6] ethernet: amd: dynamic debug fixes
Date: Mon, 14 Jul 2014 13:51:05 +0530
Message-ID: <53C392F1.7090904@gmail.com>
References: <1405319147-5212-1-git-send-email-varkabhadram@gmail.com>	 <1405319147-5212-4-git-send-email-varkabhadram@gmail.com> <1405325166.9132.40.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas.Lendacky@amd.com,
	geert+renesas@linux-m68k.org, ebiederm@xmission.com,
	macro@linux-mips.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:41921 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974AbaGNIWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 04:22:19 -0400
In-Reply-To: <1405325166.9132.40.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/14/2014 01:36 PM, Joe Perches wrote:
> On Mon, 2014-07-14 at 11:55 +0530, varkabhadram@gmail.com wrote:
>> From: Varka Bhadram <varkab@cdac.in>
> []
>> diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
> []
>> @@ -501,8 +501,7 @@ static int amd8111e_restart(struct net_device *dev)
>>   
>>   	/* Enable interrupt coalesce */
>>   	if(lp->options & OPTION_INTR_COAL_ENABLE){
>> -		printk(KERN_INFO "%s: Interrupt Coalescing Enabled.\n",
>> -								dev->name);
>> +		netdev_info(dev, "Interrupt Coalescing Enabled");
> This needs a terminating newlines.
>
>
OOOps.... I will fix it.


-- 
Regards,
Varka Bhadram.
