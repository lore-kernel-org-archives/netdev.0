From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] igmp: fix new sparse errors
Date: Wed, 12 Jun 2013 14:15:18 -0700 (PDT)
Message-ID: <20130612.141518.510334569757726138.davem@davemloft.net>
References: <1371071476.3252.66.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60272 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756972Ab3FLVPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 17:15:19 -0400
In-Reply-To: <1371071476.3252.66.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 12 Jun 2013 14:11:16 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Fix following sparse errors :
> 
> net/ipv4/igmp.c:1222:25: warning: cast from restricted __be32
> net/ipv4/igmp.c:1234:31: warning: incorrect type in assignment (different address spaces)
> net/ipv4/igmp.c:1234:31:    expected struct ip_mc_list [noderef] <asn:4>*next_hash
> net/ipv4/igmp.c:1234:31:    got struct ip_mc_list *<noident>
> net/ipv4/igmp.c:1250:31: warning: incorrect type in assignment (different address spaces)
> net/ipv4/igmp.c:1250:31:    expected struct ip_mc_list [noderef] <asn:4>*next_hash
> net/ipv4/igmp.c:1250:31:    got struct ip_mc_list *<noident>
> net/ipv4/igmp.c:2380:37: warning: cast from restricted __be32
> 
> These were added by commit e9897071350bd9
> ("igmp: hash a hash table to speedup ip_check_mc_rcu()")
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
