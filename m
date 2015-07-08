From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/7] net_sched: act: lockless operation
Date: Wed, 08 Jul 2015 13:50:55 -0700 (PDT)
Message-ID: <20150708.135055.1728112231079036434.davem@davemloft.net>
References: <1436185089-18268-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@plumgrid.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, edumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37373 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754548AbbGHUu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 16:50:56 -0400
In-Reply-To: <1436185089-18268-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Mon,  6 Jul 2015 05:18:02 -0700

> As mentioned by Alexei last week in Budapest, it is a bit weird
> to take a spinlock in order to drop a packet in a tc filter...
> 
> Lets add percpu infra for tc actions and use it for gact & mirred.
> 
> Before changes, my host with 8 RX queues was handling 5 Mpps with gact,
> and more than 11 Mpps after.
> 
> Mirred change is not yet visible if ifb+qdisc is used, as ifb is
> not yet multi queue enabled, but is a step forward.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Series applied, thanks Eric.
