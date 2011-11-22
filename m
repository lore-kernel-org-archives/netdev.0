From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: Add network priority cgroup (v4)
Date: Tue, 22 Nov 2011 15:23:15 -0500 (EST)
Message-ID: <20111122.152315.2256366823688148380.davem@davemloft.net>
References: <1321476666-8225-1-git-send-email-nhorman@tuxdriver.com>
	<1321974652-8318-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com,
	robert.w.love@intel.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53467 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756381Ab1KVUY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 15:24:26 -0500
In-Reply-To: <1321974652-8318-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 22 Nov 2011 10:10:50 -0500

> (v2)
> Based on reviews from John F., Amerigo Wang and Neerav Parikh, I've cleaned up
> the rcu locking, fixed a memory leak in an error path, and corrected some typos.
> 
> (v3)
> Converted rcu_dereference to rntl_dereference where appropriate as per request
> from John F.
> 
> (v4)
> Cleaned up some spacing issues, and optimized the skb_update_priority path as
> per request from Dave M.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> CC: Robert Love <robert.w.love@intel.com>
> CC: "David S. Miller" <davem@davemloft.net>

Applied and going through some build testing now, thanks Neil.
