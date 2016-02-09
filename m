From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] packet: tpacket gso and csum offload
Date: Tue, 09 Feb 2016 06:44:25 -0500 (EST)
Message-ID: <20160209.064425.2139335305142769623.davem@davemloft.net>
References: <1454540537-6884-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, mst@redhat.com,
	sri@us.ibm.com, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54533 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756064AbcBILo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 06:44:57 -0500
In-Reply-To: <1454540537-6884-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Wed,  3 Feb 2016 18:02:13 -0500

> From: Willem de Bruijn <willemb@google.com>
> 
> Extend PACKET_VNET_HDR socket option support to packet sockets with
> memory mapped rings.
> 
> Patches 2 and 4 add support to tpacket_rcv and tpacket_snd.
> 
> Patch 1 prepares for this by moving the relevant virtio_net_hdr
> logic out of packet_snd and packet_rcv into helper functions.
> 
> GSO transmission requires all headers in the skb linear section.
> Patch 3 moves parsing of tx_ring slot headers before skb allocation
> to enable allocation with sufficient linear size.
> 
> Changes
>   v1->v2:
>     - fix bounds checks:
>       - subtract sizeof(vnet_hdr) before comparing tp_len to size_max
>       - compare tp_len to size_max also with GSO, just do not truncate to MTU

Series applied, thanks.
