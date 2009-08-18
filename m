From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [Alacrityvm-devel] [PATCH v3 3/6] vbus: add a "vbus-proxy" bus
	model for vbus_driver objects
Date: Tue, 18 Aug 2009 23:35:22 +0300
Message-ID: <20090818203522.GA20393@redhat.com>
References: <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <20090817174142.GA11140@redhat.com> <4A89BAC5.9040400@gmail.com> <20090818084606.GA13878@redhat.com> <20090818155329.GD31060@ovro.caltech.edu> <4A8ADC09.3030205@redhat.com> <20090818172752.GC17631@ovro.caltech.edu> <4A8AE918.5000109@redhat.com> <20090818182735.GD17631@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Avi Kivity <avi@redhat.com>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090818182735.GD17631@ovro.caltech.edu>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 18, 2009 at 11:27:35AM -0700, Ira W. Snyder wrote:
> I haven't studied vhost-net very carefully yet. As soon as I saw the
> copy_(to|from)_user() I stopped reading, because it seemed useless for
> my case. I'll look again and try to find where vhost-net supports
> setting MAC addresses and other features.

vhost net doesn't do this at all. You bind raw socket to a network
device, and program that with usual userspace interfaces.

> Also, in my case I'd like to boot Linux with my rootfs over NFS. Is
> vhost-net capable of this?
> 
> I've had Arnd, BenH, and Grant Likely (and others, privately) contact me
> about devices they are working with that would benefit from something
> like virtio-over-PCI. I'd like to see vhost-net be merged with the
> capability to support my use case. There are plenty of others that would
> benefit, not just myself.
> 
> I'm not sure vhost-net is being written with this kind of future use in
> mind. I'd hate to see it get merged, and then have to change the ABI to
> support physical-device-to-device usage. It would be better to keep
> future use in mind now, rather than try and hack it in later.

I still need to think your usage over. I am not so sure this fits what
vhost is trying to do. If not, possibly it's better to just have a
separate driver for your device.


> Thanks for the comments.
> Ira
