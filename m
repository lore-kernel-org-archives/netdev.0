From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [RFC PATCH v2 19/19] virtio: add a vbus transport
Date: Sun, 09 Aug 2009 11:40:08 -0500
Message-ID: <4A7EFBE8.7050409@codemonkey.ws>
References: <20090409155200.32740.19358.stgit@dev.haskins.net> <20090409163221.32740.38373.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org, avi@redhat.com,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com, "Michael S. Tsirkin" <mst@redhat.com>
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752159AbZHIQkN@vger.kernel.org>
In-Reply-To: <20090409163221.32740.38373.stgit@dev.haskins.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory Haskins wrote:
> We add a new virtio transport for accessing backends located on vbus.  This
> complements the existing transports for virtio-pci, virtio-s390, and
> virtio-lguest that already exist.
>
> Signed-off-by: Gregory Haskins <ghaskins@novell.com>

Very interesting...

I'm somewhat confused by what you're advocating vbus as.  I'm trying to 
figure out how we converge vbus and virtio and become one big happy 
family :-)

What parts of it do you think are better than virtio?  Should we forget 
about venet and just focus on virtio-net on top of virtio-vbus assuming 
that we can prove venet-tap/virtio-vbus/virtio-net is just as good as 
venet-tap/vbus/venet?

If we can prove that an in-kernel virtio-net 
backend/virtio-pci/virtio-net does just as well as 
venet-tap/virtio-vbus/virtio-net does that mean that vbus is no longer 
needed?

If you concede that the transport mechanisms can be identical, are you 
really advocating the discovering and configuration mechanisms in vbus?  
Is that what we should be focusing on? Do you care only about the host 
mechanisms or do you also require the guest infrastructure to be present?

I think two paravirtual I/O frameworks for KVM is a bad thing.  It 
duplicates a ton of code and will very likely lead to user unhappiness.

Regards,

Anthony Liguori
