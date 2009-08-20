From: Avi Kivity <avi@redhat.com>
Subject: Re: [Alacrityvm-devel] [PATCH v3 3/6] vbus: add a "vbus-proxy" bus
 	model for vbus_driver objects
Date: Thu, 20 Aug 2009 13:08:59 +0300
Message-ID: <4A8D20BB.7020008@redhat.com>
References: <20090818172752.GC17631@ovro.caltech.edu>	 <20090818205919.GA1168@ovro.caltech.edu> <4A8B1C7F.4060008@redhat.com>	 <20090819003812.GA11168@ovro.caltech.edu>	 <4A8B9051.3020505@redhat.com>	 <20090819152811.GA22294@ovro.caltech.edu>	 <4A8C1C22.3010101@redhat.com>	 <20090819162902.GB22294@ovro.caltech.edu>	 <4A8C2A87.5060305@redhat.com>	 <1250715920.4237.26.camel@slab.beaverton.ibm.com> <fbd9d3990908200257ge4e13ceh32f28601bc0f762f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hollis Blanchard <hollisb@us.ibm.com>,
	"Ira W. Snyder" <iws@ovro.caltech.edu>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>
To: Stefan Hajnoczi <stefanha@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753871AbZHTKJd@vger.kernel.org>
In-Reply-To: <fbd9d3990908200257ge4e13ceh32f28601bc0f762f@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/20/2009 12:57 PM, Stefan Hajnoczi wrote:
> Cross-platform virtio works when endianness is known in advance.  For
> a hypervisor and a guest:
> 1. virtio-pci I/O registers use PCI endianness
> 2. vring uses guest endianness (hypervisor must byteswap)
> 3. guest memory buffers use guest endianness (hypervisor must byteswap)
>
> I know of no existing way when endianness is not known in advance.
> Perhaps a transport bit could be added to mark the endianness of the
> guest/driver side.  This can be negotiated because virtio-pci has a
> known endianness.  After negotiation, the host knows whether or not
> byteswapping is necessary for structures in guest memory.
>
>    

Some processors are capable of switching their gender at runtime, so you 
cannot tell the guest endianness in advance.

-- 
error compiling committee.c: too many arguments to function
