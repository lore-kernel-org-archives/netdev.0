From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] mlx4 bug fixes for 4.9
Date: Mon, 28 Nov 2016 15:34:05 -0500 (EST)
Message-ID: <20161128.153405.582932710660009919.davem@davemloft.net>
References: <1480267252-26146-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com,
        sebott@linux.vnet.ibm.com, swise@opengridcomputing.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41070 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751635AbcK1UeH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 15:34:07 -0500
In-Reply-To: <1480267252-26146-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Sun, 27 Nov 2016 19:20:50 +0200

> This patchset includes 2 bug fixes:
> * In patch 1 we revert the commit that avoids invoking unregister_netdev
> in shutdown flow, as it introduces netdev presence issues where
> it can be accessed unsafely by ndo operations during the flow.
> * Patch 2 is a simple fix for a variable uninitialization issue.
> 
> Series generated against net commit:
> 6998cc6ec237 tipc: resolve connection flow control compatibility problem

Series applied, thanks.
