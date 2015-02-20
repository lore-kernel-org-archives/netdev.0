From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] igmp: add __ip_mc_{join|leave}_group()
Date: Fri, 20 Feb 2015 15:24:15 -0500 (EST)
Message-ID: <20150220.152415.2055050757168148474.davem@davemloft.net>
References: <1424125238-4505-1-git-send-email-challa@noironetworks.com>
	<1424171964.4942.78.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: challa@noironetworks.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46003 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754600AbbBTUYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 15:24:18 -0500
In-Reply-To: <1424171964.4942.78.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 Feb 2015 03:19:24 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> There is a need to perform igmp join/leave operations while RTNL is
> held.
> 
> Make ip_mc_{join|leave}_group() wrappers around 
> __ip_mc_{join|leave}_group() to avoid the proliferation of work queues.
> 
> For example, vxlan_igmp_join() could possibly be removed.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
