From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] cxgb4: Update T6 Buffer Group and Channel
 Mappings
Date: Fri, 23 Jun 2017 14:22:52 -0400 (EDT)
Message-ID: <20170623.142252.535888507067541019.davem@davemloft.net>
References: <1498225477-20960-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, venkatesh@chelsio.com, leedom@chelsio.com,
        arjun@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35168 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754327AbdFWSW4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 14:22:56 -0400
In-Reply-To: <1498225477-20960-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Fri, 23 Jun 2017 19:14:36 +0530

> From: Arjun Vynipadath <arjun@chelsio.com>
> 
> We were using t4_get_mps_bg_map() for both t4_get_port_stats()
> to determine which MPS Buffer Groups to report statistics on for a given
> Port, and also for t4_sge_alloc_rxq() to provide a TP Ingress Channel
> Congestion Map.  For T4/T5 these are actually the same values (because they
> are ~somewhat~ related), but for T6 they should return different values
> (T6 has Port 0 associated with MPS Buffer Group 0 (with MPS Buffer Group 1
> silently cascading off) and Port 1 is associated with MPS Buffer Group 2
> (with 3 cascading off)).
> 
> Based on the original work by Casey Leedom <leedom@chelsio.com>
> Signed-off-by: Arjun Vynipadath <arjun@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied.
