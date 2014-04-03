From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: fix regression bug where node events are not
 being generated
Date: Thu, 03 Apr 2014 16:04:41 -0400 (EDT)
Message-ID: <20140403.160441.1850317737194356140.davem@davemloft.net>
References: <1396506481-17362-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com, maloy@donjonn.com, ying.xue@windriver.com,
	paul.gortmaker@windriver.com, richard.alpe@ericsson.com
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46590 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469AbaDCUDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 16:03:11 -0400
In-Reply-To: <1396506481-17362-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Thu, 3 Apr 2014 08:28:01 +0200

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> Commit 5902385a2440a55f005b266c93e0bb9398e5a62b ("tipc: obsolete
> the remote management feature") introduces a regression where node
> topology events are not being generated because the publication
> that triggers this: {0, <z.c.n>, <z.c.n>} is no longer available.
> This will break applications that rely on node events to discover
> when nodes join/leave a cluster.
> 
> We fix this by advertising the node publication when TIPC enters
> networking mode, and withdraws it upon shutdown.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
> Reviewed-by: Ying Xue <ying.xue@windriver.com>

Applied, thanks.
