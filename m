From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: rcu cleanup in ip_ra_control()
Date: Tue, 09 Sep 2014 20:15:13 -0700 (PDT)
Message-ID: <20140909.201513.107839060178305607.davem@davemloft.net>
References: <1410275501.7106.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35458 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753022AbaIJDPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 23:15:14 -0400
In-Reply-To: <1410275501.7106.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 09 Sep 2014 08:11:41 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Remove one sparse warning :
> net/ipv4/ip_sockglue.c:328:22: warning: incorrect type in assignment (different address spaces)
> net/ipv4/ip_sockglue.c:328:22:    expected struct ip_ra_chain [noderef] <asn:4>*next
> net/ipv4/ip_sockglue.c:328:22:    got struct ip_ra_chain *[assigned] ra
> 
> And replace one rcu_assign_ptr() by RCU_INIT_POINTER() where applicable.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
