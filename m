From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ixgbe: get rid of custom busy polling code
Date: Fri, 03 Feb 2017 17:18:06 -0500 (EST)
Message-ID: <20170203.171806.592509011760010145.davem@davemloft.net>
References: <1486081599.21871.38.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56820 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752356AbdBCWSJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 17:18:09 -0500
In-Reply-To: <1486081599.21871.38.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Feb 2017 16:26:39 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> In linux-4.5, busy polling was implemented in core
> NAPI stack, meaning that all custom implementation can
> be removed from drivers.
> 
> Not only we remove lot's of code, we also remove one lock
> operation in fast path, and allow GRO to do its job.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
