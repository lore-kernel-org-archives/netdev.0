From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] virtio_net: Add MAC and VLAN filtering
Date: Mon, 19 Jan 2009 17:10:08 -0800 (PST)
Message-ID: <20090119.171008.195637465.davem@davemloft.net>
References: <20090116211312.22836.34331.stgit@debian.lart>
	<20090118.220528.02874092.davem@davemloft.net>
	<1232353831.5627.8.camel@blaa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.williamson@hp.com, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, kvm@vger.kernel.org
To: markmc@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1232353831.5627.8.camel@blaa>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark McLoughlin <markmc@redhat.com>
Date: Mon, 19 Jan 2009 08:30:31 +0000

> virtio_net: add link status handling
> 
> Allow the host to inform us that the link is down by adding
> a VIRTIO_NET_F_STATUS which indicates that device status is
> available in virtio_net config.
> 
> This is currently useful for simulating link down conditions
> (e.g. using proposed qemu 'set_link' monitor command) but
> would also be needed if we were to support device assignment
> via virtio.
> 
> Signed-off-by: Mark McLoughlin <markmc@redhat.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au> (added future masking)

Queued up for 2.6.30, thanks!
