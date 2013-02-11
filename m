From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 0/2] netpoll: Cleanup netpoll locking and sparse
 warnings
Date: Mon, 11 Feb 2013 16:51:44 -0500
Message-ID: <20130211215144.GA2116@hmsreliant.think-freely.org>
References: <1360248961-30721-1-git-send-email-nhorman@tuxdriver.com>
 <1360614331-29247-1-git-send-email-nhorman@tuxdriver.com>
 <20130211.161135.580650334150981029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com,
	eric.dumazet@gmail.com, amwang@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36424 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932522Ab3BKVv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 16:51:56 -0500
Content-Disposition: inline
In-Reply-To: <20130211.161135.580650334150981029.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 11, 2013 at 04:11:35PM -0500, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Mon, 11 Feb 2013 15:25:29 -0500
> 
> > I was fixing some sparse warnings in netpoll from a previous commit, and it was
> > pointed out to me that one of the rcu_dereferences that I fixed up in 
> > __netpoll_cleanup might not have been correct.  On investigation I found that 
> > rtnl_dereference should have been the correct macro to use, but we had a path in
> > which we weren't properly holding the rtnl lock.  This patch series fixes up the
> > locking in the __netpoll_free_rcu path, and then properly corrects the sparse 
> > warnings in the netpoll.c file that I previously introduced.
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> I happen to know that this is meant for net-next, but you really need
> to state that clearly in your patch submissions.
> 
Understood, sorry Dave.
Neil
