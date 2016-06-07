From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] fq_codel: return non zero qlen in class dumps
Date: Tue, 07 Jun 2016 16:28:22 -0700 (PDT)
Message-ID: <20160607.162822.1382559916284413645.davem@davemloft.net>
References: <1465229559.2968.75.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59025 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752435AbcFGX2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 19:28:23 -0400
In-Reply-To: <1465229559.2968.75.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 06 Jun 2016 09:12:39 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> We properly scan the flow list to count number of packets,
> but John passed 0 to gnet_stats_copy_queue() so we report
> a zero value to user space instead of the result.
> 
> Fixes: 640158536632 ("net: sched: restrict use of qstats qlen")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: John Fastabend <john.r.fastabend@intel.com>

Applied.
