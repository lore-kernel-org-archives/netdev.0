From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use synchronize_rcu_expedited()
Date: Tue, 24 May 2011 13:28:16 -0400 (EDT)
Message-ID: <20110524.132816.495988571774322534.davem@davemloft.net>
References: <1306228052.3026.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705Ab1EXR2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 13:28:32 -0400
In-Reply-To: <1306228052.3026.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 May 2011 11:07:32 +0200

> synchronize_rcu() is very slow in various situations (HZ=100,
> CONFIG_NO_HZ=y, CONFIG_PREEMPT=n)
> 
> Extract from my (mostly idle) 8 core machine :
 ...
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
