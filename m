From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: make *udp*_queue_rcv_skb() functions static
Date: Thu, 18 May 2017 10:23:46 -0400 (EDT)
Message-ID: <20170518.102346.370962163449596599.davem@davemloft.net>
References: <8c68f6f2fb91313ab71606e42c4d3d4c561b73a9.1495024097.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43328 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756300AbdEROXt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 10:23:49 -0400
In-Reply-To: <8c68f6f2fb91313ab71606e42c4d3d4c561b73a9.1495024097.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Wed, 17 May 2017 14:52:16 +0200

> Since the udp memory accounting refactor, we don't need any more
> to export the *udp*_queue_rcv_skb(). Make them static and fix
> a couple of sparse warnings:
> 
> net/ipv4/udp.c:1615:5: warning: symbol 'udp_queue_rcv_skb' was not
> declared. Should it be static?
> net/ipv6/udp.c:572:5: warning: symbol 'udpv6_queue_rcv_skb' was not
> declared. Should it be static?
> 
> Fixes: 850cbaddb52d ("udp: use it's own memory accounting schema")
> Fixes: c915fe13cbaa ("udplite: fix NULL pointer dereference")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied.
