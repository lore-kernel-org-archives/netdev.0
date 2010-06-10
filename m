From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv6: mcast: RCU conversions
Date: Wed, 09 Jun 2010 18:07:37 -0700 (PDT)
Message-ID: <20100609.180737.48514741.davem@davemloft.net>
References: <1275980702.2775.193.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56215
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756665Ab0FJBH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 21:07:26 -0400
In-Reply-To: <1275980702.2775.193.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 08 Jun 2010 09:05:02 +0200

> - ipv6_sock_mc_join() : doesnt touch dev refcount
> 
> - ipv6_sock_mc_drop() : doesnt touch dev/idev refcounts
> 
> - ip6_mc_find_dev() becomes ip6_mc_find_dev_rcu() (called from rcu),
>                     and doesnt touch dev/idev refcounts
> 
> - ipv6_sock_mc_close() : doesnt touch dev/idev refcounts
> 
> - ip6_mc_source() uses ip6_mc_find_dev_rcu()
> 
> - ip6_mc_msfilter() uses ip6_mc_find_dev_rcu()
> 
> - ip6_mc_msfget() uses ip6_mc_find_dev_rcu()
> 
> - ipv6_dev_mc_dec(), ipv6_chk_mcast_addr(),
>   igmp6_event_query(), igmp6_event_report(),
>   mld_sendpack(), igmp6_send() dont touch idev refcount
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
