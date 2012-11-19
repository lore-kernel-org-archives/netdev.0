From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/17] Make the network stack usable by userns
 root
Date: Sun, 18 Nov 2012 22:26:01 -0500 (EST)
Message-ID: <20121118.222601.1683927229305655885.davem@davemloft.net>
References: <87d2zd8zwn.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	serge@hallyn.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54333 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859Ab2KSD0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Nov 2012 22:26:05 -0500
In-Reply-To: <87d2zd8zwn.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 16 Nov 2012 05:01:44 -0800

> 
> In a secondary user namespace the root user only has CAP_NET_ADMIN,
> CAP_NET_RAW and CAP_NET_BIND_SERVICE with respect to the secondary user
> namespace.  The test "capable(CAP_NET_ADMIN)" tests for capabilities in
> the initial user namespace.
> 
> The following set of patches goes through the networking stack.  First
> pushing the capable(CAP_NET_ADMIN) admin calls down farther in the stack
> so individual instances can be changed.  Then where I have I it appears
> safe I have relaxed the permission checks.
> 
> The code is available in git from:
> git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git netns-v73
> 
> The netns-v73 branch is against v3.7-rc3 and merges cleanly with net-next.
> 
> In my user namespace tree I am working to allow unprivileged users to
> create user namespace, and to allow the user namespace root able to
> create network namespaces.  Making these patches really about allowing
> unprivileged users able to use the networking stack (not that they will
> be able to talk to anyone).
> 
> David I have some small dependencies on the first two patches of this
> series in my later user namespace work.  So after these changes have
> been reviewed if you can pull my netns-v73 branch (which is just these
> patches) into net-next that will help me avoid unnecessary conflicts.

There were merge issues so I applied the patches and sorted the
conflicts out one-by-one.

I hope this doesn't cause major problems.
