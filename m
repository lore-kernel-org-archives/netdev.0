From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH 0/4] virtio_net: MAC filtering
Date: Tue, 13 Jan 2009 14:23:15 -0700
Message-ID: <1231881795.9095.185.camel@bling>
References: <1231351559.7109.128.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kvm <kvm@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Mark McLoughlin <markmc@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1231351559.7109.128.camel@lappy>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here's an update to the patches I sent last week.  The goal of this
series is to add RX mode bits, MAC table filtering, and I'll follow up
with VLAN filtering, so that the virtio_net device doesn't always run in
promiscuous mode.

This version now uses a virtqueue for outbound commands for setting mode
bits and table entries.  The size of the MAC filter table can be
configured by the guest at initialization.  I'm no longer bloating the
I/O port space of the virtnet device, in fact, I couldn't find any
reason to store the RX mode bits in the status register, so I also moved
those into the virtqueue channel so we have less shared data.  Please
comment.  Thanks,

Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

