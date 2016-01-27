From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] tipc: fix connection abort during subscription
 cancel
Date: Wed, 27 Jan 2016 17:08:50 -0500 (EST)
Message-ID: <20160127.170850.1011664949543122106.davem@davemloft.net>
References: <1453890959-8238-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com, maloy@donjonn.com, ying.xue@windriver.com,
	richard.alpe@ericsson.com, anders.widell@ericsson.com
To: parthasarathy.bhuvaragan@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934332AbcA0WIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 17:08:53 -0500
In-Reply-To: <1453890959-8238-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Date: Wed, 27 Jan 2016 11:35:59 +0100

> In 'commit 7fe8097cef5f ("tipc: fix nullpointer bug when subscribing
> to events")', we terminate the connection if the subscription
> creation fails.
> In the same commit, the subscription creation result was based on
> the value of the subscription pointer (set in the function) instead
> of the return code.
> 
> Unfortunately, the same function tipc_subscrp_create() handles
> subscription cancel request. For a subscription cancellation request,
> the subscription pointer cannot be set. Thus if a subscriber has
> several subscriptions and cancels any of them, the connection is
> terminated.
> 
> In this commit, we terminate the connection based on the return value
> of tipc_subscrp_create().
> Fixes: commit 7fe8097cef5f ("tipc: fix nullpointer bug when subscribing to events")
> 
> Reviewed-by:  Jon Maloy <jon.maloy@ericsson.com>
> Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>

Applied and queued up for -stable, thanks.
