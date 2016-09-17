From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: Free skb on irda_accept error path.
Date: Sat, 17 Sep 2016 10:00:43 -0400 (EDT)
Message-ID: <20160917.100043.1998184424644024855.davem@davemloft.net>
References: <20160915164144.24472-1-phil.turnbull@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samuel@sortiz.org
To: phil.turnbull@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60114 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751269AbcIQOAq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 10:00:46 -0400
In-Reply-To: <20160915164144.24472-1-phil.turnbull@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Turnbull <phil.turnbull@oracle.com>
Date: Thu, 15 Sep 2016 12:41:44 -0400

> skb is not freed if newsk is NULL. Rework the error path so free_skb is
> unconditionally called on function exit.
> 
> Fixes: c3ea9fa27413 ("[IrDA] af_irda: IRDA_ASSERT cleanups")
> Signed-off-by: Phil Turnbull <phil.turnbull@oracle.com>

Applied.
