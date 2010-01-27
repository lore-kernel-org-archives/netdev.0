From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH net-next-2.6] packet: Add GSO/checksum offload support to af_packet sockets
Date: Wed, 27 Jan 2010 12:22:48 +1030
Message-ID: <201001271222.48195.rusty@rustcorp.com.au>
References: <1264537819.24933.122.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:44860 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751673Ab0A0Bwz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2010 20:52:55 -0500
In-Reply-To: <1264537819.24933.122.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Jan 2010 07:00:19 am Sridhar Samudrala wrote:
> This patch adds GSO/checksum offload to af_packet sockets using
> virtio_net_hdr. Based on Rusty's patch to add this support to tun.
> It allows GSO/checksum offload to be enabled when using raw socket
> backend with virtio_net.
> Adds PACKET_VNET_HDR socket option to prepend virtio_net_hdr in the
> receive path and process/skip virtio_net_hdr in the send path. This
> option is only allowed with SOCK_RAW sockets attached to ethernet
> type devices.

This is really MST's baby, so I'm going to defer to his wisdom on this...

Cheers,
Rusty.
