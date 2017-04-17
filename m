From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,1/2] hv_netvsc: Fix the queue index
 computation in forwarding case
Date: Mon, 17 Apr 2017 11:05:37 -0400 (EDT)
Message-ID: <20170417.110537.1356623047459405667.davem@davemloft.net>
References: <1492022106-4070-1-git-send-email-haiyangz@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com, haiyangz@exchange.microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53334 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752932AbdDQPFk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 11:05:40 -0400
In-Reply-To: <1492022106-4070-1-git-send-email-haiyangz@exchange.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Date: Wed, 12 Apr 2017 11:35:05 -0700

> From: Haiyang Zhang <haiyangz@microsoft.com>
> 
> If the outgoing skb has a RX queue mapping available, we use the queue
> number directly, other than put it through Send Indirection Table.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied.
