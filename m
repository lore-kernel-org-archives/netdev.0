From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: Fix MAX_PACKET_LEN to support 802.1Q VLANs
Date: Sun, 25 Jan 2009 18:06:43 -0800 (PST)
Message-ID: <20090125.180643.147283270.davem@davemloft.net>
References: <20090120164822.10112.89512.stgit@debian.lart>
	<1232470766.5277.18.camel@blaa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.williamson@hp.com, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, kvm@vger.kernel.org
To: markmc@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1232470766.5277.18.camel@blaa>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark McLoughlin <markmc@redhat.com>
Date: Tue, 20 Jan 2009 16:59:26 +0000

> On Tue, 2009-01-20 at 09:48 -0700, Alex Williamson wrote:
> 
> > 802.1Q expanded the maximum ethernet frame size by 4 bytes for the
> > VLAN tag.  We're not taking this into account in virtio_net, which
> > means the buffers we provide to the backend in the virtqueue RX ring
> > aren't big enough to hold a full MTU VLAN packet.  For QEMU/KVM,
> > this results in the backend exiting with a packet truncation error.
> > 
> > Signed-off-by: Alex Williamson <alex.williamson@hp.com>
> 
> Acked-by: Mark McLoughlin <markmc@redhat.com>
> 
> Note 1: this only matters if the guest isn't using mergeable receive
> buffers or GSO
> 
> Note 2: IMHO, this should go in 2.6.29 and stable

Applied and queued up for -stable, thanks everyone!
