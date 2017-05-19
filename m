From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next PATCH 2/5] mlx5: fix bug reading rss_hash_type
 from CQE
Date: Fri, 19 May 2017 19:38:18 -0400 (EDT)
Message-ID: <20170519.193818.1096111302686413939.davem@davemloft.net>
References: <149512205297.14733.15729847433404265933.stgit@firesoul>
        <149512209807.14733.12774004120782832472.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: borkmann@iogearbox.net, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59232 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756906AbdESXi0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 19:38:26 -0400
In-Reply-To: <149512209807.14733.12774004120782832472.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 18 May 2017 17:41:38 +0200

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

Please pass this along to the mlx5 developers as a standalone
bug fix for 'net', thank you.
