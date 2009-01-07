From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH 0/2][RFC] virtio_net: MAC filtering
Date: Wed, 07 Jan 2009 11:05:59 -0700
Message-ID: <1231351559.7109.128.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kvm <kvm@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Mark McLoughlin <markmc@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This series builds on some of the patches Mark McLoughlin has sent out
recently, so likely won't apply to any current trees until those get
upstream.  The goal is to enable MAC filtering at the kvm/qemu level for
virtio-net packets.  Promiscuous and allmulti mode are handled by adding
bits to Mark's proposed status field.  I also add a 16 entry MAC table
for additional unicast and multicast addresses to filter.  If this looks
reasonable, I'll follow-up with VLAN filtering.

As noted in the RFC thread adding the kvm/qemu backing, this does
increase the size of the virtio-net device I/O port space, up to 1kB
with PCI rounding if we add a 4k entry VLAN bitmap.  A 64 device limit
is still pretty high for a VM, but maybe we should think about adding
MMIO space for virtio-pci.  Thanks,

Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

