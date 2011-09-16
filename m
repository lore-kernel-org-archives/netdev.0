From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Fix fib_info->fib_metrics leak
Date: Fri, 16 Sep 2011 18:58:24 -0400 (EDT)
Message-ID: <20110916.185824.913892518307815959.davem@davemloft.net>
References: <4E646B14.1020801@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, laijs@cn.fujitsu.com
To: zheng.z.yan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44456 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932454Ab1IPW6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 18:58:31 -0400
In-Reply-To: <4E646B14.1020801@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yan, Zheng" <zheng.z.yan@intel.com>
Date: Mon, 05 Sep 2011 14:24:20 +0800

> Commit 4670994d(net,rcu: convert call_rcu(fc_rport_free_rcu) to
> kfree_rcu()) introduced a memory leak. This patch reverts it.
> 
> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>

Applied.
