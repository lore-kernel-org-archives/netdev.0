From: Avi Kivity <avi@redhat.com>
Subject: Re: [Alacrityvm-devel] [PATCH v3 3/6] vbus: add a "vbus-proxy" bus
 model for vbus_driver objects
Date: Tue, 18 Aug 2009 19:51:21 +0300
Message-ID: <4A8ADC09.3030205@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <20090817174142.GA11140@redhat.com> <4A89BAC5.9040400@gmail.com> <20090818084606.GA13878@redhat.com> <20090818155329.GD31060@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759415AbZHRQvr@vger.kernel.org>
In-Reply-To: <20090818155329.GD31060@ovro.caltech.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/18/2009 06:53 PM, Ira W. Snyder wrote:
> So, in my system, copy_(to|from)_user() is completely wrong. There is no
> userspace, only a physical system. In fact, because normal x86 computers
> do not have DMA controllers, the host system doesn't actually handle any
> data transfer!
>    

In fact, modern x86s do have dma engines these days (google for Intel 
I/OAT), and one of our plans for vhost-net is to allow their use for 
packets above a certain size.  So a patch allowing vhost-net to 
optionally use a dma engine is a good thing.

> I used virtio-net in both the guest and host systems in my example
> virtio-over-PCI patch, and succeeded in getting them to communicate.
> However, the lack of any setup interface means that the devices must be
> hardcoded into both drivers, when the decision could be up to userspace.
> I think this is a problem that vbus could solve.
>    

Exposing a knob to userspace is not an insurmountable problem; vhost-net 
already allows changing the memory layout, for example.

-- 
error compiling committee.c: too many arguments to function
