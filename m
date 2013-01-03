From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Correctly unregister MDB rtnetlink handlers
Date: Thu, 03 Jan 2013 01:56:39 -0800 (PST)
Message-ID: <20130103.015639.300000536792223155.davem@davemloft.net>
References: <1357155685-14672-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50076 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753027Ab3ACJ4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 04:56:40 -0500
In-Reply-To: <1357155685-14672-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Wed,  2 Jan 2013 14:41:25 -0500

> Commit 63233159fd4e596568f5f168ecb0879b61631d47:
>     bridge: Do not unregister all PF_BRIDGE rtnl operations
> introduced a bug where a removal of a single bridge from a
> multi-bridge system would remove MDB netlink handlers.
> The handlers should only be removed once all bridges are gone, but
> since we don't keep track of the number of bridge interfaces, it's
> simpler to do it when the bridge module is unloaded.  To make it
> consistent, move the registration code into module initialization
> code path.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Applied, thanks.
