From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH] virtio_net: Fix MAX_PACKET_LEN to support 802.1Q VLANs
Date: Tue, 20 Jan 2009 16:59:26 +0000
Message-ID: <1232470766.5277.18.camel@blaa>
References: <20090120164822.10112.89512.stgit@debian.lart>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au, kvm@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34511 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754189AbZATQ7h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2009 11:59:37 -0500
In-Reply-To: <20090120164822.10112.89512.stgit@debian.lart>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-01-20 at 09:48 -0700, Alex Williamson wrote:

> 802.1Q expanded the maximum ethernet frame size by 4 bytes for the
> VLAN tag.  We're not taking this into account in virtio_net, which
> means the buffers we provide to the backend in the virtqueue RX ring
> aren't big enough to hold a full MTU VLAN packet.  For QEMU/KVM,
> this results in the backend exiting with a packet truncation error.
> 
> Signed-off-by: Alex Williamson <alex.williamson@hp.com>

Acked-by: Mark McLoughlin <markmc@redhat.com>

Note 1: this only matters if the guest isn't using mergeable receive
buffers or GSO

Note 2: IMHO, this should go in 2.6.29 and stable

Cheers,
Mark.

