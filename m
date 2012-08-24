From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cls_cgroup: Allow classifier cgroups to have their
 classid reset to 0
Date: Fri, 24 Aug 2012 12:41:47 -0400 (EDT)
Message-ID: <20120824.124147.1315942233312740114.davem@davemloft.net>
References: <1345485550-15556-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54130 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964937Ab2HXQlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 12:41:51 -0400
In-Reply-To: <1345485550-15556-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 20 Aug 2012 13:59:10 -0400

> The network classifier cgroup initalizes each cgroups instance classid value to
> 0.  However, the sock_update_classid function only updates classid's in sockets
> if the tasks cgroup classid is not zero, and if it differs from the current
> classid.  The later check is to prevent cache line dirtying, but the former is
> detrimental, as it prevents resetting a classid for a cgroup to 0.  While this
> is not a common action, it has administrative usefulness (if the admin wants to
> disable classification of a certain group temporarily for instance).
> 
> Easy fix, just remove the zero check.  Tested successfully by myself
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied to net-next, thanks Neil.
