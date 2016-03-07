From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v1 1/1] tipc: fix nullptr crash during subscription
 cancel
Date: Sun, 06 Mar 2016 23:01:03 -0500 (EST)
Message-ID: <20160306.230103.935516724641513071.davem@davemloft.net>
References: <1457024094-29530-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com, maloy@donjonn.com, ying.xue@windriver.com
To: parthasarathy.bhuvaragan@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43055 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752008AbcCGEBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 23:01:05 -0500
In-Reply-To: <1457024094-29530-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Date: Thu, 3 Mar 2016 17:54:54 +0100

> commit 4d5cfcba2f6e ('tipc: fix connection abort during subscription
> cancel'), removes the check for a valid subscription before calling
> tipc_nametbl_subscribe().
> 
> This will lead to a nullptr exception when we process a
> subscription cancel request. For a cancel request, a null
> subscription is passed to tipc_nametbl_subscribe() resulting
> in exception.
> 
> In this commit, we call tipc_nametbl_subscribe() only for
> a valid subscription.
> 
> Fixes: 4d5cfcba2f6e ('tipc: fix connection abort during subscription cancel')
> Reported-by: Anders Widell <anders.widell@ericsson.com>
> Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
> Acked-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.
