From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix return values of l2tp_dfs_seq_open()
Date: Sun, 05 Jun 2011 14:11:34 -0700 (PDT)
Message-ID: <20110605.141134.1930414354785145137.davem@davemloft.net>
References: <20110604222531.GA11521@ZenIV.linux.org.uk>
	<20110605103735.GB11521@ZenIV.linux.org.uk>
	<20110605105403.GC11521@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53110 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754650Ab1FEVLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2011 17:11:47 -0400
In-Reply-To: <20110605105403.GC11521@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Sun, 5 Jun 2011 11:54:03 +0100

> More fallout from struct net lifetime rules review: PTR_ERR() is *already*
> negative and failing ->open() should return negatives on failure.
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

Al, I applied this and your get_net_ns_by_fd() fix to my net-2.6
tree.

Thanks!
