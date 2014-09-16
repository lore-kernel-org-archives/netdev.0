From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 1/4] net: sched: fix unsued cpu variable
Date: Tue, 16 Sep 2014 16:00:01 -0400 (EDT)
Message-ID: <20140916.160001.1211965286020279308.davem@davemloft.net>
References: <20140916063024.2905.55403.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250AbaIPUAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 16:00:04 -0400
In-Reply-To: <20140916063024.2905.55403.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Mon, 15 Sep 2014 23:30:26 -0700

> kbuild test robot reported an unused variable cpu in cls_u32.c
> after the patch below. This happens when PERF and MARK config
> variables are disabled
> 
> Fix this is to use separate variables for perf and mark
> and define the cpu variable inside the ifdef logic.
> 
> 'commit 459d5f626da7 ("net: sched: make cls_u32 per cpu")'
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
