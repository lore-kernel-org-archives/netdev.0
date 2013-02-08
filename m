From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] netpoll: cleanup sparse warnings
Date: Fri, 8 Feb 2013 13:14:33 -0500
Message-ID: <20130208181433.GC8771@hmsreliant.think-freely.org>
References: <1360248961-30721-1-git-send-email-nhorman@tuxdriver.com>
 <1360252376.28557.52.camel@edumazet-glaptop>
 <20130207183725.GE2379@shamino.rdu.redhat.com>
 <1360293933.28557.92.camel@edumazet-glaptop>
 <20130208154727.GB8771@hmsreliant.think-freely.org>
 <1360341883.28557.106.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59271 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946728Ab3BHSOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 13:14:42 -0500
Content-Disposition: inline
In-Reply-To: <1360341883.28557.106.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 08, 2013 at 08:44:43AM -0800, Eric Dumazet wrote:
> On Fri, 2013-02-08 at 10:47 -0500, Neil Horman wrote:
> 
> > Actually, I think all we need to do is take the rcu_read_lock and use
> > rcu_dereference directly.  __netpoll_cleanup doesn't actually change the
> > dev->npinfo pointer itself, thats handled by the caller, always under protection
> > of the rtnl, so here we just need to ensure that no one changes npifo while
> > we're using it
> 
> SGTM ;)
> 
Testing it out now.  The more I look at this the more I'm concerned that there
are other problems with netpoll in the release path.  Shocking...I know :)
Neil

> 
> 
