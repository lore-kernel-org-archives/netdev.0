From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: l2tp_eth: fix kernel panic on rmmod l2tp_eth
Date: Thu, 07 Jun 2012 13:02:53 -0700 (PDT)
Message-ID: <20120607.130253.603912969641143376.davem@davemloft.net>
References: <1339060346.26966.106.camel@edumazet-glaptop>
	<66de011eba423f7b5eeb3c57e8430c5a@visp.net.lb>
	<1339063640.26966.113.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org, jchapman@katalix.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45305 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743Ab2FGUC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 16:02:57 -0400
In-Reply-To: <1339063640.26966.113.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Jun 2012 12:07:20 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> We must prevent module unloading if some devices are still attached to
> l2tp_eth driver.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Tested-by: Denys Fedoryshchenko <denys@visp.net.lb>
Applied.
