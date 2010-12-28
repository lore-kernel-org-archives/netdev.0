From: David Miller <davem@davemloft.net>
Subject: Re: [patch] skfp: testing the wrong variable in skfp_driver_init()
Date: Tue, 28 Dec 2010 13:55:15 -0800 (PST)
Message-ID: <20101228.135515.48512926.davem@davemloft.net>
References: <20101224051734.GO1936@bicker>
	<20101224084538.GA2791@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, netdev@vger.kernel.org, eric.dumazet@gmail.com,
	hsweeten@visionengravers.com, kernel-janitors@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58486
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751642Ab0L1Vyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Dec 2010 16:54:45 -0500
In-Reply-To: <20101224084538.GA2791@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Fri, 24 Dec 2010 09:45:39 +0100

> Fri, Dec 24, 2010 at 06:17:34AM CET, error27@gmail.com wrote:
>>The intent here was to test if the allocation failed but we tested 
>>"SharedMemSize" instead of "SharedMemAddr" by mistake.
>>
>>Signed-off-by: Dan Carpenter <error27@gmail.com>
>>
>>diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
>>index 0a66fed..16c6265 100644
>>--- a/drivers/net/skfp/skfddi.c
>>+++ b/drivers/net/skfp/skfddi.c
>>@@ -412,7 +412,7 @@ static  int skfp_driver_init(struct net_device *dev)
>> 		bp->SharedMemAddr = pci_alloc_consistent(&bp->pdev,
>> 							 bp->SharedMemSize,
>> 							 &bp->SharedMemDMA);
>>-		if (!bp->SharedMemSize) {
>>+		if (!bp->SharedMemAddr) {
>> 			printk("could not allocate mem for ");
>> 			printk("hardware module: %ld byte\n",
>> 			       bp->SharedMemSize);
> 
> Looks obvious.
> 
> Reviewed-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks.
