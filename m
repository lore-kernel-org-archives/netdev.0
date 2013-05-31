From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: emaclite: Fix typo in error message
Date: Fri, 31 May 2013 16:36:13 -0700 (PDT)
Message-ID: <20130531.163613.1343522161135384248.davem@davemloft.net>
References: <51A87BB6.7060207@efe-gmbh.de>
	<51A87D32.9010006@monstr.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: renner@efe-gmbh.de, netdev@vger.kernel.org
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42873 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755009Ab3EaXgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 19:36:14 -0400
In-Reply-To: <51A87D32.9010006@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Simek <monstr@monstr.eu>
Date: Fri, 31 May 2013 12:36:34 +0200

> On 05/31/2013 12:30 PM, Jens Renner (EFE) wrote:
>> s/allocal/allocate/
>> 
>> Signed-off-by: Jens Renner <renner@efe-gmbh.de>
>> ---
>> drivers/net/ethernet/xilinx/xilinx_emaclite.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
>> index aa14d8a..aaadf7e 100644
>> --- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
>> +++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
>> @@ -877,7 +877,7 @@ static int xemaclite_mdio_setup(struct net_local *lp, struct device *dev)
>> 
>>         bus = mdiobus_alloc();
>>         if (!bus) {
>> -               dev_err(dev, "Failed to allocal mdiobus\n");
>> +               dev_err(dev, "Failed to allocate mdiobus\n");
>>                 return -ENOMEM;
>>         }
> 
> Acked-by: Michal Simek <monstr@monstr.eu>

You're acking a patch that is corrupted by the submitter's email client
and won't even apply :-)
