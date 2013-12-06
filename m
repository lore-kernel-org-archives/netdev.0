From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: consistent use of IP6_INC_STATS_BH() in
 ip6_forward()
Date: Fri, 06 Dec 2013 12:52:10 -0500 (EST)
Message-ID: <20131206.125210.2242120304270061238.davem@davemloft.net>
References: <1386308286.30495.227.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40728 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932081Ab3LFRwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 12:52:11 -0500
In-Reply-To: <1386308286.30495.227.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Dec 2013 21:38:06 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> ip6_forward() runs from softirq context, we can use the SNMP macros
> assuming this.
> 
> Use same indentation for all IP6_INC_STATS_BH() calls.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
