From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: move xdp_prog field in RX cache lines
Date: Tue, 25 Apr 2017 16:25:51 -0400 (EDT)
Message-ID: <20170425.162551.60261849156169066.davem@davemloft.net>
References: <1493145412.6453.45.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44882 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947156AbdDYUZy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 16:25:54 -0400
In-Reply-To: <1493145412.6453.45.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 25 Apr 2017 11:36:52 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> (struct net_device, xdp_prog) field should be moved in RX cache lines,
> reducing latencies when a single packet is received on idle host,
> since netif_elide_gro() needs it.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Sure, applied, thanks Eric!
