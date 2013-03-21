From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] gianfar: Remove 'maybe-uninitialized'
 compile warning
Date: Thu, 21 Mar 2013 12:02:04 -0400 (EDT)
Message-ID: <20130321.120204.1455321557089470604.davem@davemloft.net>
References: <1363871535-29612-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43715 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933858Ab3CUQCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 12:02:06 -0400
In-Reply-To: <1363871535-29612-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Thu, 21 Mar 2013 15:12:13 +0200

> Warning message:
> warning: 'budget_per_q' may be used uninitialized in this function
> 
> budget_per_q won't be used uninitialized since the only time
> it doesn't get initialized is when entering gfar_poll with
> num_act_queues == 0, meaning rstat_rxf == 0, in which case
> budget_per_q is not utilized (as it has no meaning).
> Inititalize budget_per_q to 0 though to suppress this compile
> warning.
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied.
