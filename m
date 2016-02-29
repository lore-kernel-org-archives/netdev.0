From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v3 0/4] net_sched: update backlog for
 hierarchical qdisc's
Date: Mon, 29 Feb 2016 17:03:07 -0500 (EST)
Message-ID: <20160229.170307.974750252299252960.davem@davemloft.net>
References: <1456440903-32335-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52122 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750712AbcB2WDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 17:03:09 -0500
In-Reply-To: <1456440903-32335-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 25 Feb 2016 14:54:59 -0800

> For hierarchical qdisc like HTB, we currently only update its qlen
> but leave its backlog as zero:
> 
>     qdisc htb 1: dev eth0 root refcnt 2 r2q 10 default 1 direct_packets_stat 0 ver 3.17
>      Sent 172680457356 bytes 222469449 pkt (dropped 0, overlimits 123575834 requeues 0)
>      backlog 0b 72p requeues 0
> 
> This patchset makes backlog as accurate as qlen.
> 
> ---
> v3: rebase and fix the n==0 case for qdisc_tree_reduce_backlog()
> v2: rebase and update changelog, not code change

Series applied, thanks.
