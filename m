From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sis900: Fix the tx queue timeout issue
Date: Wed, 31 Jul 2013 17:18:51 -0700 (PDT)
Message-ID: <20130731.171851.260577748566053117.davem@davemloft.net>
References: <1375281782-2332-1-git-send-email-kda@linux-powerpc.org>
	<20130731.171738.741214690208351644.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: venza@brownhat.org, netdev@vger.kernel.org
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36104 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857Ab3HAASw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 20:18:52 -0400
In-Reply-To: <20130731.171738.741214690208351644.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 31 Jul 2013 17:17:38 -0700 (PDT)

> From: Denis Kirjanov <kda@linux-powerpc.org>
> Date: Wed, 31 Jul 2013 18:43:02 +0400
> 
>> +			printk(KERN_DEBUG "%s: Auto negotiation in progress\n",
>> +					net_dev->name);
> 
> Please use "pr_debug()"

Or even better "netdev_debug()", that way you don't need the
"%s: " prefix in the string at all.
