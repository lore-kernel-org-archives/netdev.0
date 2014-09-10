From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netns: remove one sparse warning
Date: Tue, 09 Sep 2014 20:15:28 -0700 (PDT)
Message-ID: <20140909.201528.1233511656443579673.davem@davemloft.net>
References: <1410276293.7106.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35465 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752396AbaIJDP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 23:15:28 -0400
In-Reply-To: <1410276293.7106.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 09 Sep 2014 08:24:53 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> net/core/net_namespace.c:227:18: warning: incorrect type in argument 1
> (different address spaces)
> net/core/net_namespace.c:227:18:    expected void const *<noident>
> net/core/net_namespace.c:227:18:    got struct net_generic [noderef]
> <asn:4>*gen
> 
> We can use rcu_access_pointer() here as read-side access to the pointer
> was removed at least one grace period ago.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
