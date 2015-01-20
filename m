From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: ratelimit network event traces
Date: Mon, 19 Jan 2015 19:46:31 -0500 (EST)
Message-ID: <20150119.194631.158476804095735240.davem@davemloft.net>
References: <1421658164-26185-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richard.alpe@ericsson.com, ying.xue@windriver.com,
	jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174AbbATAqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 19:46:33 -0500
In-Reply-To: <1421658164-26185-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Mon, 19 Jan 2015 10:02:44 +0100

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> If a large number of namespaces is spawned on a node and TIPC is
> enabled in each of these, the excessive printk tracing of network
> events will cause the system to grind down to a near halt.
> We fix this by adding ratelimiting to the info/warning logs
> regarding link state and node availability.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Reviewed-by: Ying Xue <ying.xue@windriver.com>

Really these various state transition messages that are enabled
by default really should not be.

If you want to watch for every event like this, listen on a
netlink socket or set some debugging level param to some non-
default value.
