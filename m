From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v1 1/1] tipc: fix nametbl deadlock at
 tipc_nametbl_unsubscribe
Date: Wed, 22 Mar 2017 11:59:59 -0700 (PDT)
Message-ID: <20170322.115959.957088455820539447.davem@davemloft.net>
References: <1490089669-2144-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
        jon.maloy@ericsson.com, maloy@donjonn.com, ying.xue@windriver.com,
        thompa.atl@gmail.com
To: parthasarathy.bhuvaragan@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43112 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934477AbdCVTAB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 15:00:01 -0400
In-Reply-To: <1490089669-2144-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Date: Tue, 21 Mar 2017 10:47:49 +0100

> From: Ying Xue <ying.xue@windriver.com>
> 
> Until now, tipc_nametbl_unsubscribe() is called at subscriptions
> reference count cleanup. Usually the subscriptions cleanup is
> called at subscription timeout or at subscription cancel or at
> subscriber delete.
> 
> We have ignored the possibility of this being called from other
> locations, which causes deadlock as we try to grab the
> tn->nametbl_lock while holding it already.
 ...
> In this commit, we advance the calling of tipc_nametbl_unsubscribe()
> from the refcount cleanup to the intended callers.
> 
> Fixes: d094c4d5f5c7 ("tipc: add subscription refcount to avoid invalid delete")
> Reported-by: John Thompson <thompa.atl@gmail.com>
> Acked-by: Jon Maloy <jon.maloy@ericsson.com>
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>

Applied, thank you.
