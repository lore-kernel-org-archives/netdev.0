From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] tipc: remove pre-allocated message header
 in link struct
Date: Sun, 06 Mar 2016 23:01:50 -0500 (EST)
Message-ID: <20160306.230150.2115988710117845238.davem@davemloft.net>
References: <1457033001-31227-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43080 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752008AbcCGEBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 23:01:52 -0500
In-Reply-To: <1457033001-31227-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu,  3 Mar 2016 14:23:21 -0500

> Until now, we have kept a pre-allocated protocol message header
> aggregated into struct tipc_link. Apart from adding unnecessary
> footprint to the link instances, this requires extra code both to
> initialize and re-initialize it.
> 
> We now remove this sub-optimization. This change also makes it
> possible to clean up the function tipc_build_proto_msg() and remove
> a couple of small functions that were accessing the mentioned header.
> In particular, we can replace all occurrences of the local function
> call link_own_addr(link) with the generic tipc_own_addr(net).
> 
> Acked-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks.
