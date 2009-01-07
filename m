From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH 0/2][RFC] virtio_net: MAC filtering
Date: Wed, 07 Jan 2009 12:14:51 -0600
Message-ID: <4964F11B.7020509@codemonkey.ws>
References: <1231351559.7109.128.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, kvm <kvm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Mark McLoughlin <markmc@redhat.com>
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1231351559.7109.128.camel@lappy>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alex Williamson wrote:
> This series builds on some of the patches Mark McLoughlin has sent out
> recently, so likely won't apply to any current trees until those get
> upstream.  The goal is to enable MAC filtering at the kvm/qemu level for
> virtio-net packets.  Promiscuous and allmulti mode are handled by adding
> bits to Mark's proposed status field.  I also add a 16 entry MAC table
> for additional unicast and multicast addresses to filter.  If this looks
> reasonable, I'll follow-up with VLAN filtering.
>
> As noted in the RFC thread adding the kvm/qemu backing, this does
> increase the size of the virtio-net device I/O port space, up to 1kB
> with PCI rounding if we add a 4k entry VLAN bitmap.  A 64 device limit
> is still pretty high for a VM, but maybe we should think about adding
> MMIO space for virtio-pci.  Thanks,
>   

I'm not quite sure the best way to address this.  Maybe another control 
queue for sending commands to control this sort of stuff?  What are your 
thoughts Rusty?

Regards,

Anthony Liguori

> Alex
>
>   

