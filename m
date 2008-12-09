From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net: add link status handling
Date: Wed, 10 Dec 2008 10:23:41 +1030
Message-ID: <200812101023.42365.rusty@rustcorp.com.au>
References: <1228817973.26198.1.camel@blaa> <493EE3DE.7080702@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	netdev <netdev@vger.kernel.org>, kvm <kvm@vger.kernel.org>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <493EE3DE.7080702@codemonkey.ws>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 10 December 2008 08:02:14 Anthony Liguori wrote:
> Mark McLoughlin wrote:
> > Allow the host to inform us that the link is down by adding
> > a VIRTIO_NET_F_STATUS which indicates that device status is
> > available in virtio_net config.
> > 
> > This is currently useful for simulating link down conditions
> > (e.g. using proposed qemu 'set_link' monitor command) but
> > would also be needed if we were to support device assignment
> > via virtio.
> 
> It would be nice if the virtio-net card wrote some acknowledgement that 
> it has received the link status down/up events.

How about of every status change event? ie. a generic virtio_pci solution?

Rusty.
