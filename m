From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v2 2/2] virtio_net: Defer skb allocation in receive path
Date: Sun, 17 Jan 2010 08:01:12 +1030
Message-ID: <201001170801.12721.rusty@rustcorp.com.au>
References: <1261122090.4148.24.camel@localhost.localdomain> <1263236965.11949.1.camel@localhost.localdomain> <1263416018.29594.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Amit Shah <amit.shah@redhat.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48067 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750743Ab0AQARv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Jan 2010 19:17:51 -0500
In-Reply-To: <1263416018.29594.1.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Jan 2010 07:23:38 am Shirley Ma wrote:
> virtio_net receives packets from its pre-allocated vring buffers, then it 
> delivers these packets to upper layer protocols as skb buffs. So it's not
> necessary to pre-allocate skb for each mergable buffer, then frees extra 
> skbs when buffers are merged into a large packet. This patch has deferred 
> skb allocation in receiving packets for both big packets and mergeable buffers
> to reduce skb pre-allocations and skb frees. It frees unused buffers by calling 
> detach_unused_buf in vring, so recv skb queue is not needed.
> 
> Signed-off-by: Shirley Ma <xma@us.ibm.com>

Thanks, applied!

After testing I'll send it to DaveM.

Rusty.
