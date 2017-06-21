From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] udp: prefetch rmem_alloc in
 udp_queue_rcv_skb()
Date: Wed, 21 Jun 2017 11:41:55 -0400 (EDT)
Message-ID: <20170621.114155.502883498671476879.davem@davemloft.net>
References: <ec963336242664e99c2f47f399c621aa7f5e2885.1498033422.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40502 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752993AbdFUQUt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 12:20:49 -0400
In-Reply-To: <ec963336242664e99c2f47f399c621aa7f5e2885.1498033422.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Wed, 21 Jun 2017 10:24:40 +0200

> On UDP packets processing, if the BH is the bottle-neck, it
> always sees a cache miss while updating rmem_alloc; try to
> avoid it prefetching the value as soon as we have the socket
> available.
> 
> Performances under flood with multiple NIC rx queues used are
> unaffected, but when a single NIC rx queue is in use, this
> gives ~10% performance improvement.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied, but what about ipv6?
