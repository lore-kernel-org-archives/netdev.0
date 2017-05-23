From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] mlx5: fix bug reading rss_hash_type from CQE
Date: Tue, 23 May 2017 11:03:47 -0400 (EDT)
Message-ID: <20170523.110347.1398145896069831101.davem@davemloft.net>
References: <149547678696.10455.14428063974882319686.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, borkmann@iogearbox.net,
        netdev@vger.kernel.org, tariqt@mellanox.com,
        alexei.starovoitov@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35960 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030813AbdEWPDw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 11:03:52 -0400
In-Reply-To: <149547678696.10455.14428063974882319686.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 22 May 2017 20:13:07 +0200

> Masks for extracting part of the Completion Queue Entry (CQE)
> field rss_hash_type was swapped, namely CQE_RSS_HTYPE_IP and
> CQE_RSS_HTYPE_L4.
> 
> The bug resulted in setting skb->l4_hash, even-though the
> rss_hash_type indicated that hash was NOT computed over the
> L4 (UDP or TCP) part of the packet.
> 
> Added comments from the datasheet, to make it more clear what
> these masks are selecting.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Applied, thanks Jesper.
