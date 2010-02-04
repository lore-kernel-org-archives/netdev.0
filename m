From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next-2.6] packet: Add GSO/csum offload support.
Date: Thu, 04 Feb 2010 15:49:01 -0800 (PST)
Message-ID: <20100204.154901.232299310.davem@davemloft.net>
References: <1265239340.5600.21.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, mst@redhat.com, netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47178
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932660Ab0BDXss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 18:48:48 -0500
In-Reply-To: <1265239340.5600.21.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Wed, 03 Feb 2010 15:22:20 -0800

> This patch adds GSO/checksum offload to af_packet sockets using
> virtio_net_hdr. Based on Rusty's patch to add this support to tun.
> It allows GSO/checksum offload to be enabled when using raw socket
> backend with virtio_net.
> Adds PACKET_VNET_HDR socket option to prepend virtio_net_hdr in the
> receive path and process/skip virtio_net_hdr in the send path. This
> option is only allowed with SOCK_RAW sockets attached to ethernet
> type devices.
> 
> v2 updates
> ----------
> Michael's Comments
> - Perform length check in packet_snd() when GSO is off even when
>   vnet_hdr is present.
> - Check for SKB_GSO_FCOE type and return -EINVAL
> - don't allow tx/rx ring when vnet_hdr is enabled.
> Herbert's Comments
> - Removed ethernet specific code.
> - protocol value is assumed to be passed in by the caller.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Herbert et al. could you guys review this?

Thanks.
