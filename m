From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 v2] pkt_sched: gen_estimator: add a new lock
Date: Thu, 10 Jun 2010 22:54:41 -0700 (PDT)
Message-ID: <20100610.225441.258124673.davem@davemloft.net>
References: <1275929761.2545.159.camel@edumazet-laptop>
	<1275931108.2545.168.camel@edumazet-laptop>
	<1276076350.2442.90.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org, shemminger@vyatta.com,
	jarkao2@gmail.com, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59304
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751997Ab0FKFya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 01:54:30 -0400
In-Reply-To: <1276076350.2442.90.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 09 Jun 2010 11:39:10 +0200

> [PATCH net-2.6 v2] pkt_sched: gen_estimator: add a new lock
> 
> gen_kill_estimator() / gen_new_estimator() is not always called with
> RTNL held.
> 
> net/netfilter/xt_RATEEST.c is one user of these API that do not hold
> RTNL, so random corruptions can occur between "tc" and "iptables".
> 
> Add a new fine grained lock instead of trying to use RTNL in netfilter.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Wow, a lot of discussion to read and digest for this one :-)

Applied, thanks!
