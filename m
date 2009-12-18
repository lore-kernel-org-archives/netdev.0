From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH net-next 0/2] Defer skb allocation in virtio_net recv
Date: Thu, 17 Dec 2009 23:41:30 -0800
Message-ID: <1261122090.4148.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:37457 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752413AbZLRHlf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2009 02:41:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch-set has deferred virtio_net skb allocation in receiving path
for both big packets and mergeable buffers. It reduces skb
pre-allocations and skb frees. This patch-set also add a new API
detach_unused_bufs in virtio. Recv skb queue has been removed in
virtio_net. It is based on previous Rusty and Michaels' review, patch
has split into two:

[PATCH 1/2] virtio: Add detach unused buffer from vring
[PATCH 2/2] virtio_net: Defer skb allocation in receive path

I copied Rusty's comment as [PATCH 1/2] commit message.

This patch is built against Dave's net-next tree.

Thanks
Shirley

 


