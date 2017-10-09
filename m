From: David Miller <davem@davemloft.net>
Subject: Re: [net 1/1] tipc: correct initialization of skb list
Date: Sun, 08 Oct 2017 21:13:48 -0700 (PDT)
Message-ID: <20171008.211348.246107050516376717.davem@davemloft.net>
References: <1507379569-26507-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, parthasarathy.bhuvaragan@ericsson.com,
        ying.xue@windriver.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38850 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751738AbdJIENt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:13:49 -0400
In-Reply-To: <1507379569-26507-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Sat, 7 Oct 2017 14:32:49 +0200

> We change the initialization of the skb transmit buffer queues
> in the functions tipc_bcast_xmit() and tipc_rcast_xmit() to also
> initialize their spinlocks. This is needed because we may, during
> error conditions, need to call skb_queue_purge() on those queues
> further down the stack.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.
