From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] virtio_net: Defer skb allocation in receive path
 Date: Wed, 13 Jan 2010 12:53:38 -0800
Date: Tue, 02 Feb 2010 15:59:16 -0800 (PST)
Message-ID: <20100202.155916.136472373.davem@davemloft.net>
References: <201001292346.43675.rusty@rustcorp.com.au>
	<201001292349.05360.rusty@rustcorp.com.au>
	<201001292350.04544.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	mashirle@us.ibm.com, mst@redhat.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45567
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755905Ab0BBX7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 18:59:03 -0500
In-Reply-To: <201001292350.04544.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Fri, 29 Jan 2010 23:50:04 +1030

> From: Shirley Ma <mashirle@us.ibm.com>
> 
> virtio_net receives packets from its pre-allocated vring buffers, then it 
> delivers these packets to upper layer protocols as skb buffs. So it's not
> necessary to pre-allocate skb for each mergable buffer, then frees extra 
> skbs when buffers are merged into a large packet. This patch has deferred 
> skb allocation in receiving packets for both big packets and mergeable buffers
> to reduce skb pre-allocations and skb frees. It frees unused buffers by calling 
> detach_unused_buf in vring, so recv skb queue is not needed.
> 
> Signed-off-by: Shirley Ma <xma@us.ibm.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Applied.
