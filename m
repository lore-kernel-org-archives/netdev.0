From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v1 0/3] net sched rcu updates
Date: Mon, 06 Oct 2014 18:03:01 -0400 (EDT)
Message-ID: <20141006.180301.251258497544909892.davem@davemloft.net>
References: <20141006042335.6010.27000.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org, jhs@mojatatu.com,
	eric.dumazet@gmail.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38608 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131AbaJFWDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 18:03:05 -0400
In-Reply-To: <20141006042335.6010.27000.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Sun, 05 Oct 2014 21:27:25 -0700

> This fixes the use of tcf_proto from RCU callbacks it requires
> moving the unbind calls out of the callbacks and removing the
> tcf_proto argument from the tcf_em_tree_destroy().
> 
> This is a rework of two previous series and addresses comments
> from Cong. And should apply against latest net-next.
> 
> The previous series links below for reference:
> 
> (1/2) net: sched: do not use tcf_proto 'tp' argument from call_rcu
> http://patchwork.ozlabs.org/patch/396149/ 
> 
> (2/2) net: sched: replace ematch calls to use struct net
> http://patchwork.ozlabs.org/patch/396150/
> 
> 
> net: sched: cls_cgroup tear down exts and ematch from rcu callback
> http://patchwork.ozlabs.org/patch/396307/

Series applied, thanks.
