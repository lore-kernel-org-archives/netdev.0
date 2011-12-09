From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "net: netprio_cgroup: make net_prio_subsys
 static"
Date: Fri, 09 Dec 2011 13:39:39 -0500 (EST)
Message-ID: <20111209.133939.436181697690796163.davem@davemloft.net>
References: <20111209170325.26422.11885.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44355 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169Ab1LISkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2011 13:40:47 -0500
In-Reply-To: <20111209170325.26422.11885.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Fri, 09 Dec 2011 09:03:25 -0800

> This reverts commit 865d9f9f748fdc1943679ea65d9ee1dc55e4a6ae.
> 
> This commit breaks the build with CONFIG_NETPRIO_CGROUP=y so
> revert it. It does build as a module though. The SUBSYS macro
> in the cgroup core code automatically defines a subsys structure
> as extern. Long term we should fix the macro. And I need to
> fully build test things.
> 
> Tested with CONFIG_NETPRIO_CGROUP={y|m|n} with and without
> CONFIG_CGROUPS defined.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> CC: Neil Horman <nhorman@tuxdriver.com>
> Reported-By: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
