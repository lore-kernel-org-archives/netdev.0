From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 3/4] net: sched: cls_cgroup fix possible
 memory leak of 'new'
Date: Tue, 16 Sep 2014 16:00:14 -0400 (EDT)
Message-ID: <20140916.160014.443414280812410039.davem@davemloft.net>
References: <20140916063024.2905.55403.stgit@nitbit.x32>
	<20140916063115.2905.53827.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755322AbaIPUAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 16:00:16 -0400
In-Reply-To: <20140916063115.2905.53827.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Mon, 15 Sep 2014 23:31:17 -0700

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   54996b529ab70ca1d6f40677cd2698c4f7127e87
> commit: c7953ef23042b7c4fc2be5ecdd216aacff6df5eb [625/646] net: sched: cls_cgroup use RCU
> 
> net/sched/cls_cgroup.c:130 cls_cgroup_change() warn: possible memory leak of 'new'
> net/sched/cls_cgroup.c:135 cls_cgroup_change() warn: possible memory leak of 'new'
> net/sched/cls_cgroup.c:139 cls_cgroup_change() warn: possible memory leak of 'new'
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
