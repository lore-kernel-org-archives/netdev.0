From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] flowcache: Tune per cpu flow cache shrink size
Date: Fri, 14 Mar 2014 14:43:48 -0400 (EDT)
Message-ID: <20140314.144348.286366646093321442.davem@davemloft.net>
References: <1394782966-9792-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38517 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753644AbaCNSnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 14:43:50 -0400
In-Reply-To: <1394782966-9792-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Fri, 14 Mar 2014 15:42:46 +0800

> When per cpu flow cache entries count reaches over high_watermark,
> flow cache will be shrinked gently to around low_watermark, not
> brutally killing most of cached entries by left only two.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>

We are limiting hash chain lengths, not total hash table size.

Your change is therefore not appropriate.
