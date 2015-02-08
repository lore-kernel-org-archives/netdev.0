From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: use netif_rx_ni() from process context
Date: Sat, 07 Feb 2015 22:44:23 -0800 (PST)
Message-ID: <20150207.224423.203725892895019100.davem@davemloft.net>
References: <1423177094.31870.93.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47215 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbbBHGoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 01:44:24 -0500
In-Reply-To: <1423177094.31870.93.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Feb 2015 14:58:14 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Hotpluging a cpu might be rare, yet we have to use proper
> handlers when taking over packets found in backlog queues.
> 
> dev_cpu_callback() runs from process context, thus we should
> call netif_rx_ni() to properly invoke softirq handler.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> I never saw real operational issues, but I suspect this patch cannot
> hurt.

Applied, thanks.
