From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] netpoll: Cleanup netpoll locking and sparse
 warnings
Date: Mon, 11 Feb 2013 16:11:35 -0500 (EST)
Message-ID: <20130211.161135.580650334150981029.davem@davemloft.net>
References: <1360248961-30721-1-git-send-email-nhorman@tuxdriver.com>
	<1360614331-29247-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com,
	eric.dumazet@gmail.com, amwang@redhat.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42467 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932078Ab3BKVLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 16:11:36 -0500
In-Reply-To: <1360614331-29247-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 11 Feb 2013 15:25:29 -0500

> I was fixing some sparse warnings in netpoll from a previous commit, and it was
> pointed out to me that one of the rcu_dereferences that I fixed up in 
> __netpoll_cleanup might not have been correct.  On investigation I found that 
> rtnl_dereference should have been the correct macro to use, but we had a path in
> which we weren't properly holding the rtnl lock.  This patch series fixes up the
> locking in the __netpoll_free_rcu path, and then properly corrects the sparse 
> warnings in the netpoll.c file that I previously introduced.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

I happen to know that this is meant for net-next, but you really need
to state that clearly in your patch submissions.
