From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] virtio_net: exploit napi_complete_done()
 return value
Date: Sat, 04 Feb 2017 19:39:01 -0500 (EST)
Message-ID: <20170204.193901.790935994094939434.davem@davemloft.net>
References: <1486223361.21871.136.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com, mst@redhat.com,
        willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55876 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751239AbdBEAjF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 19:39:05 -0500
In-Reply-To: <1486223361.21871.136.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 04 Feb 2017 07:49:21 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Since commit 364b6055738b ("net: busy-poll: return busypolling status to
> drivers"), napi_complete_done() returns a boolean that can be used
> by drivers to conditionally rearm interrupts.
> 
> This patch changes virtio_net to use this boolean to avoid a bit of
> overhead for busy-poll users.
> 
> Jason reports about 1.1% improvement for 1 byte TCP_RR (burst 100).
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Jason Wang <jasowang@redhat.com>

Applied.
