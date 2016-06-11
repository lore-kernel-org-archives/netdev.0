From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net_sched: remove qdisc_is_throttled()
Date: Fri, 10 Jun 2016 23:37:07 -0700 (PDT)
Message-ID: <20160610.233707.1963309173677043993.davem@davemloft.net>
References: <1465602099-15808-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35298 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbcFKGhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 02:37:09 -0400
In-Reply-To: <1465602099-15808-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Fri, 10 Jun 2016 16:41:35 -0700

> HTB, CBQ and HFSC pay a very high cost updating the qdisc 'throttled'
> status that nothing but CBQ seems to use.
> 
> CBQ usage is flaky anyway, since no qdisc ->enqueue() updates the
> 'throttled' qdisc status.
> 
> This looks like some 'optimization' that actually cost more than code
> without the optimization, and might cause latency issues with CBQ.
> 
> In my tests, I could achieve a 8 % performance increase in TCP_RR
> workload through HTB qdisc, in presence of throttled classes,
> and 5 % without throttled classes.

Series applied, thanks.
