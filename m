From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -net v2 0/2] net: netpoll and netconsole fixes
Date: Thu, 19 Sep 2013 14:16:53 -0400 (EDT)
Message-ID: <20130919.141653.1263304026565052808.davem@davemloft.net>
References: <1379595756-3527-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53418 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752716Ab3ISSQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 14:16:54 -0400
In-Reply-To: <1379595756-3527-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Thu, 19 Sep 2013 15:02:34 +0200

> This small patchset fixes a possible race condition in netpoll_cleanup
> which can lead to a NULL pointer dereference because the check and
> manipulation of np->dev are done outside of the rtnl lock (patch 01).
> The second patch fixes a deadlock in netconsole and does a trivial comment
> style fix.

Both applied and queued up for -stable, thanks.
