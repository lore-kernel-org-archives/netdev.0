From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-next tree related)
Date: Fri, 12 Apr 2013 03:08:07 -0400 (EDT)
Message-ID: <20130412.030807.2228977831606614404.davem@davemloft.net>
References: <20130412160018.3d54c801f40fbc13058ded07@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, stephen@networkplumber.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130412160018.3d54c801f40fbc13058ded07@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 12 Apr 2013 16:00:18 +1000

> After merging the final tree, today's linux-next build (powerpc
> allyesconfig) failed like this:
> 
> net/core/netprio_cgroup.c:250:29: error: static declaration of 'net_prio_subsys' follows non-static declaration
> include/linux/cgroup_subsys.h:71:1: note: previous declaration of 'net_prio_subsys' was here
> 
> Caused by commit 763eff57de89 ("netprio_cgroup: make local table static")
> from the net-next tree.
> 
> I have reverted that commit for today.

I've reverted it from net-next too, thanks Stephen.

> /me hates macros that construct symbols ...

/me hates automatic checkers that don't expand macros :-)
