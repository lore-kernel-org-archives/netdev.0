From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH net v2 3/7] net: cpmac: dynamic debug fixes
Date: Thu, 10 Jul 2014 15:05:39 +0530
Message-ID: <53BE5E6B.1070209@gmail.com>
References: <1404970545-26508-1-git-send-email-varkabhadram@gmail.com>	 <1404970545-26508-4-git-send-email-varkabhadram@gmail.com>	 <1404981109.8839.6.camel@joe-AO725> <53BE52B7.40107@gmail.com> <1404983014.8839.8.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	linux@rainbow-software.org, balbi@ti.com, george.cherian@ti.com,
	davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:33190 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051AbaGJJgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 05:36:52 -0400
Received: by mail-pd0-f173.google.com with SMTP id r10so10587291pdi.32
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 02:36:52 -0700 (PDT)
In-Reply-To: <1404983014.8839.8.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/2014 02:33 PM, Joe Perches wrote:
> On Thu, 2014-07-10 at 14:15 +0530, Varka Bhadram wrote:
>> Hi,
> Hello.
>
>> This series already applied to net-next by David Miller.
> You could improve it anyway.
>
>> Anyway we will discuss this. If change required i will send the patch
>>
>> On 07/10/2014 02:01 PM, Joe Perches wrote:
>>> On Thu, 2014-07-10 at 11:05 +0530, varkabhadram@gmail.com wrote:
>>>> From: Varka Bhadram <varkab@cdac.in>
>>>>
>>>> This patch does the following changes
>>>> 1. convert printk(KERN_DEBUG.. to netdev_dbg() if we have net_device object
>>>>      or convert to dev_dbg() if we have device object.
>>> []
>>>> diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
>>> []
>>>> @@ -228,21 +228,20 @@ static void cpmac_dump_regs(struct net_device *dev)
>>>>    		if (i % 16 == 0) {
>>>>    			if (i)
>>>>    				pr_cont("\n");
>>>> -			printk(KERN_DEBUG "%s: reg[%p]:", dev->name,
>>>> -			       priv->regs + i);
>>>> +			netdev_dbg(dev, "reg[%p]:", priv->regs + i);
>>>>    		}
>>>> -		printk(" %08x", cpmac_read(priv->regs, i));
>>>> +		pr_debug(" %08x", cpmac_read(priv->regs, i));
>> You mean to say that the pr_debug will insert the new line ?... I dont think so..
> Try it.
>
> If you're using dynamic_debug, remember to
> enable all the lines.
>
>
Ya you are correct. New line inserted when i use pr_debug().
I will submit the patch for this.

Thanks.

-- 
Regards,
Varka Bhadram.
