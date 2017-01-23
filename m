From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx5e: Do not recycle pages from emergency
 reserve
Date: Mon, 23 Jan 2017 10:45:40 -0500 (EST)
Message-ID: <20170123.104540.2005179027278796046.davem@davemloft.net>
References: <CAPe+=50xs=MMqxHPgTiGa3qytL7633Cygf_vBWuAuq=ceLyacg@mail.gmail.com>
        <CALzJLG9JEorLwV48H3m0vQ1+VDnpYbKhiBoUw+WW-JFouJoj1g@mail.gmail.com>
        <20170123093940.5d69539e@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@dev.mellanox.co.il, tom@herbertland.com,
        saeedm@mellanox.com, netdev@vger.kernel.org, tariqt@mellanox.com,
        eric.dumazet@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42036 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750705AbdAWPpo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 10:45:44 -0500
In-Reply-To: <20170123093940.5d69539e@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 23 Jan 2017 09:39:40 +0100

> BUT there are other advantages of using a guaranteed recycle pool
> facility (like the page_pool).  Namely, (1) DMA-overhead: keeping page
> DMA mapped to counter DMA+IOMMU overhead, (2) RX-zero-copy: opens up
> for a software memory model solution for pre-VMA-mapping pages to
> userspace (See: [1] for argument how this avoids leaking kernel mem,
> but only expose/leak packet-data mem)

+1
