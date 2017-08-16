From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ptr_ring: use kmalloc_array()
Date: Wed, 16 Aug 2017 16:29:15 -0700 (PDT)
Message-ID: <20170816.162915.89069404027644244.davem@davemloft.net>
References: <1502905007.4936.133.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, jasowang@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40932 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752444AbdHPX3Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 19:29:16 -0400
In-Reply-To: <1502905007.4936.133.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Aug 2017 10:36:47 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> As found by syzkaller, malicious users can set whatever tx_queue_len
> on a tun device and eventually crash the kernel.
> 
> Lets remove the ALIGN(XXX, SMP_CACHE_BYTES) thing since a small
> ring buffer is not fast anyway.
> 
> Fixes: 2e0ab8ca83c1 ("ptr_ring: array based FIFO for pointers")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied and queued up for -stable.
