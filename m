From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: get rid of custom busy poll code
Date: Fri, 03 Feb 2017 16:18:32 -0500 (EST)
Message-ID: <20170203.161832.2031732898225323624.davem@davemloft.net>
References: <1486064667.21871.32.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ganeshgr@chelsio.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53460 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752331AbdBCVSe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:18:34 -0500
In-Reply-To: <1486064667.21871.32.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Feb 2017 11:44:27 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> In linux-4.5, busy polling was implemented in core
> NAPI stack, meaning that all custom implementation can
> be removed from drivers.
> 
> Not only we remove lot of code, we also remove one spin_lock()
> from driver fast path.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
