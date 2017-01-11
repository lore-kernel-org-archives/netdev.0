From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] netvsc: add rcu_read locking to netvsc callback
Date: Wed, 11 Jan 2017 16:31:01 -0500 (EST)
Message-ID: <20170111.163101.2187875318579580298.davem@davemloft.net>
References: <20170111171632.31241-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59916 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757355AbdAKVbD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 16:31:03 -0500
In-Reply-To: <20170111171632.31241-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 11 Jan 2017 09:16:32 -0800

> The receive callback (in tasklet context) is using RCU to get reference
> to associated VF network device but this is not safe. RCU read lock
> needs to be held. Found by running with full lockdep debugging
> enabled.
> 
> Fixes: f207c10d9823 ("hv_netvsc: use RCU to protect vf_netdev")
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
> ---
> v2 - fix commit message

Applied and queued up for -stable.
