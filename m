From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC net-next PATCH 2/5] mlx5: fix bug reading rss_hash_type
 from CQE
Date: Mon, 22 May 2017 20:27:40 +0200
Message-ID: <20170522202740.6ed57978@redhat.com>
References: <149512205297.14733.15729847433404265933.stgit@firesoul>
        <149512209807.14733.12774004120782832472.stgit@firesoul>
        <20170519.193818.1096111302686413939.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: borkmann@iogearbox.net, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59596 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933452AbdEVS14 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 14:27:56 -0400
In-Reply-To: <20170519.193818.1096111302686413939.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 May 2017 19:38:18 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Jesper Dangaard Brouer <brouer@redhat.com>
> Date: Thu, 18 May 2017 17:41:38 +0200
> 
> > Masks for extracting part of the Completion Queue Entry (CQE)
> > field rss_hash_type was swapped, namely CQE_RSS_HTYPE_IP and
> > CQE_RSS_HTYPE_L4.
> > 
> > The bug resulted in setting skb->l4_hash, even-though the
> > rss_hash_type indicated that hash was NOT computed over the
> > L4 (UDP or TCP) part of the packet.
> > 
> > Added comments from the datasheet, to make it more clear what
> > these masks are selecting.
> > 
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>  
> 
> Please pass this along to the mlx5 developers as a standalone
> bug fix for 'net', thank you.

Done, send as separate patch.
 http://patchwork.ozlabs.org/patch/765537/

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
