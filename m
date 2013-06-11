From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ti davinci_mdio: don't hold a spin lock while
 calling pm_runtime
Date: Tue, 11 Jun 2013 02:26:46 -0700 (PDT)
Message-ID: <20130611.022646.1941931287963046172.davem@davemloft.net>
References: <1370451240-30153-1-git-send-email-bigeasy@linutronix.de>
	<51AF6EDE.8020905@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bigeasy@linutronix.de, netdev@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37490 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752478Ab3FKJ0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 05:26:47 -0400
In-Reply-To: <51AF6EDE.8020905@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Wed, 5 Jun 2013 22:31:18 +0530

> On 6/5/2013 10:24 PM, Sebastian Andrzej Siewior wrote:
>> was playing with suspend and run into this:
 ...
>> I don't see a reason why the pm_runtime call must be under the lock.
>> Further I don't understand why this is a spinlock and not mutex.
>>
>> Cc: Mugunthan V N <mugunthanvnm@ti.com>
>> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
 ...
> Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied, thanks.
