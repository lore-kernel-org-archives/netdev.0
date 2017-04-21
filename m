From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netpoll: Check for skb->queue_mapping
Date: Fri, 21 Apr 2017 15:45:54 -0400 (EDT)
Message-ID: <20170421.154554.219059312422333404.davem@davemloft.net>
References: <1492729051-4269-1-git-send-email-tushar.n.dave@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, edumazet@google.com, netdev@vger.kernel.org,
        sowmini.varadhan@oracle.com
To: tushar.n.dave@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37728 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425561AbdDUTqG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:46:06 -0400
In-Reply-To: <1492729051-4269-1-git-send-email-tushar.n.dave@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Dave <tushar.n.dave@oracle.com>
Date: Thu, 20 Apr 2017 15:57:31 -0700

> Reducing real_num_tx_queues needs to be in sync with skb queue_mapping
> otherwise skbs with queue_mapping greater than real_num_tx_queues
> can be sent to the underlying driver and can result in kernel panic.
> 
> One such event is running netconsole and enabling VF on the same
> device. Or running netconsole and changing number of tx queues via
> ethtool on same device.
 ...
> Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
> ---
> v1->v2:
> - addressed comments from Eric Dumazet.

Applied and queued up for -stable, thanks!
