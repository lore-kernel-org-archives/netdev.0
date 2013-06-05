From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: emaclite: Use platform resource table
Date: Tue, 04 Jun 2013 17:39:27 -0700 (PDT)
Message-ID: <20130604.173927.1262961402705099933.davem@davemloft.net>
References: <6ece0a9ee777b987ca777a338cc146ed67897529.1370340196.git.michal.simek@xilinx.com>
	<201306042210.05844.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michal.simek@xilinx.com, linux-kernel@vger.kernel.org,
	monstr@monstr.eu, wfp5p@virginia.edu, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990Ab3FEAj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 20:39:28 -0400
In-Reply-To: <201306042210.05844.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 4 Jun 2013 22:10:05 +0200

> On Tuesday 04 June 2013, Michal Simek wrote:
>>   Read data directly from platform recource table
>> and do not use of_irq_to_resource().
>> Also use devm_request_and_ioremap() for probe
>> functions simplification.
>> 
>> Signed-off-by: Michal Simek <michal.simek@xilinx.com>
>> ---
>> Based on my discussion with Arnd
>> "[PATCH] net: emaclite: include linux/of_irq.h"
>> 
> 
> Acked-by: Arnd Bergmann <arnd@arndb.de>

Applied to net-next, thanks.
