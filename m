From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv4: Properly purge netdev references on uncached
 routes.
Date: Fri, 24 Aug 2012 11:45:37 -0400 (EDT)
Message-ID: <20120824.114537.1737590837215529536.davem@davemloft.net>
References: <20120731154455.2acf97a8@nehalam.linuxnetplumber.net>
	<20120731.160408.994710172149748635.davem@davemloft.net>
	<1345822847.19483.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53707 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759566Ab2HXPpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 11:45:41 -0400
In-Reply-To: <1345822847.19483.8.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 24 Aug 2012 17:40:47 +0200

> We might have an SMP performance regression on multicast traffic,
> because DST_NOCACHE is set on such routes.
> 
> What about the following ?

I'm fine with this and will apply it to 'net', thanks Eric!
