From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH v2] net: sched: lock imbalance in hhf qdisc
Date: Sun, 04 May 2014 19:42:23 -0400 (EDT)
Message-ID: <20140504.194223.1807538065295254407.davem@davemloft.net>
References: <20140501162300.17183.83124.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	edumazet@google.com, vtlam@google.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695AbaEDXmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 19:42:25 -0400
In-Reply-To: <20140501162300.17183.83124.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Thu, 01 May 2014 09:23:06 -0700

> hhf_change() takes the sch_tree_lock and releases it but misses the
> error cases. Fix the missed case here.
> 
> To reproduce try a command like this,
> 
> # tc qdisc change dev p3p2 root hhf quantum 40960 non_hh_weight 300000
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied and queued up for -stable, thanks.
