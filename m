From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] cxgb4: Use Firmware params to get
 buffer-group map
Date: Fri, 23 Jun 2017 14:23:02 -0400 (EDT)
Message-ID: <20170623.142302.617436337536411857.davem@davemloft.net>
References: <1498225477-20960-1-git-send-email-ganeshgr@chelsio.com>
        <1498225477-20960-2-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, venkatesh@chelsio.com, leedom@chelsio.com,
        arjun@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35176 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754327AbdFWSXE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 14:23:04 -0400
In-Reply-To: <1498225477-20960-2-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Fri, 23 Jun 2017 19:14:37 +0530

> From: Arjun Vynipadath <arjun@chelsio.com>
> 
> Buffer group mappings can be obtained using FW_PARAMs cmd for newer FW.
> 
> Since some of the bg_maps are obtained in atomic context, created another
> t4_query_params_ns(), that wont sleep when awaiting mbox cmd completion.
> 
> Signed-off-by: Casey Leedom <leedom@chelsio.com>
> Signed-off-by: Arjun Vynipadath <arjun@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied.
