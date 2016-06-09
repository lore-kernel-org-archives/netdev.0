From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] net: macvlan: call
 netdev_lockdep_set_classes()
Date: Thu, 09 Jun 2016 00:03:21 -0700 (PDT)
Message-ID: <20160609.000321.180046215105603933.davem@davemloft.net>
References: <1465430127-22993-1-git-send-email-edumazet@google.com>
	<1465430127-22993-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com,
	eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42230 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161015AbcFIHDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 03:03:22 -0400
In-Reply-To: <1465430127-22993-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Wed,  8 Jun 2016 16:55:26 -0700

> In case a qdisc is used on a macvlan device, we need to use different
> lockdep classes to avoid false positives.
> 
> Fixes: f9eb8aea2a1e ("net_sched: transform qdisc running bit into a seqcount")
> Fixes: 79640a4ca695 ("net: add additional lock to qdisc to increase throughput")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
