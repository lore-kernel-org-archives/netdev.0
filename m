From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: fix a race in egress prio management
Date: Thu, 18 Jul 2013 13:07:34 -0700 (PDT)
Message-ID: <20130718.130734.1267527837449730772.davem@davemloft.net>
References: <1374157166.6097.28.camel@edumazet-glaptop>
	<1374162570.6097.33.camel@edumazet-glaptop>
	<1374165310.6097.39.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37907 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933442Ab3GRUHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 16:07:35 -0400
In-Reply-To: <1374165310.6097.39.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 18 Jul 2013 09:35:10 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> egress_priority_map[] hash table updates are protected by rtnl,
> and we never remove elements until device is dismantled.
> 
> We have to make sure that before inserting an new element in hash table,
> all its fields are committed to memory or else another cpu could
> find corrupt values and crash.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
