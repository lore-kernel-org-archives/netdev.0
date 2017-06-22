From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] udp/v6: prefetch rmem_alloc in
 udp6_queue_rcv_skb()
Date: Thu, 22 Jun 2017 13:44:20 -0400 (EDT)
Message-ID: <20170622.134420.722849803202881288.davem@davemloft.net>
References: <9152ab05a2fe6b6230b44b7a23056b367ca19f5e.1498127002.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39164 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751224AbdFVRoV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 13:44:21 -0400
In-Reply-To: <9152ab05a2fe6b6230b44b7a23056b367ca19f5e.1498127002.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Thu, 22 Jun 2017 15:01:22 +0200

> very similar to commit dd99e425be23 ("udp: prefetch
> rmem_alloc in udp_queue_rcv_skb()"), this allows saving a cache
> miss when the BH is bottle-neck for UDP over ipv6 packet
> processing, e.g. for small packets when a single RX NIC ingress
> queue is in use.
> 
> Performances under flood when multiple NIC RX queues used are
> unaffected, but when a single NIC rx queue is in use, this
> gives ~8% performance improvement.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied but please look into that DNS lookup regression which was
reported today.

Thank you.
