From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ixgbevf: get rid of custom busy polling code
Date: Fri, 03 Feb 2017 17:18:12 -0500 (EST)
Message-ID: <20170203.171812.1875718788043890596.davem@davemloft.net>
References: <1486083558.21871.42.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56828 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752376AbdBCWST (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 17:18:19 -0500
In-Reply-To: <1486083558.21871.42.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Feb 2017 16:59:18 -0800

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
