From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] Fix hardcoded interrupt name lp->name to use system
 device value
Date: Fri, 27 Sep 2013 17:40:16 -0400 (EDT)
Message-ID: <20130927.174016.941418306620142265.davem@davemloft.net>
References: <1379789381-3992-1-git-send-email-thenaterhood@gmail.com>
	<20130923022532.GA17124@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thenaterhood@gmail.com, netdev@vger.kernel.org
To: tedheadster@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51018 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752322Ab3I0VkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 17:40:17 -0400
In-Reply-To: <20130923022532.GA17124@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Whitehead <tedheadster@gmail.com>
Date: Sun, 22 Sep 2013 22:25:33 -0400

> On Sat, Sep 21, 2013 at 06:49:41PM +0000, Nate Levesque wrote:
>> The lance interrupt handler was using the hard-coded name which would make it difficult to tell where the interrupt came from. Changed to use the device name that made the interrupt.
>> 
>> Signed-off-by: Nate Levesque <thenaterhood@gmail.com>
>> ---
>>  drivers/net/ethernet/amd/lance.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/drivers/net/ethernet/amd/lance.c b/drivers/net/ethernet/amd/lance.c
>> index 5c72843..256f590 100644
>> --- a/drivers/net/ethernet/amd/lance.c
>> +++ b/drivers/net/ethernet/amd/lance.c
>> @@ -754,7 +754,7 @@ lance_open(struct net_device *dev)
>>  	int i;
>>  
>>  	if (dev->irq == 0 ||
>> -		request_irq(dev->irq, lance_interrupt, 0, lp->name, dev)) {
>> +		request_irq(dev->irq, lance_interrupt, 0, dev->name, dev)) {
>>  		return -EAGAIN;
>>  	}
>>  
>> -- 
>> 1.8.1.2
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> Reviewed-by: Matthew Whitehead <tedheadster@gmail.com>

Applied but please use a more appriate subsystem prefix in your Subject
lines, in this case you could say "lance: " after "[net-next] "
