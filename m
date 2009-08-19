From: Hollis Blanchard <hollisb@us.ibm.com>
Subject: Re: [Alacrityvm-devel] [PATCH v3 3/6] vbus: add a "vbus-proxy" bus
 model for vbus_driver objects
Date: Wed, 19 Aug 2009 14:05:20 -0700
Message-ID: <1250715920.4237.26.camel@slab.beaverton.ibm.com>
References: <20090818172752.GC17631@ovro.caltech.edu>
	 <4A8AE918.5000109@redhat.com> <20090818182735.GD17631@ovro.caltech.edu>
	 <4A8AF880.6080704@redhat.com> <20090818205919.GA1168@ovro.caltech.edu>
	 <4A8B1C7F.4060008@redhat.com> <20090819003812.GA11168@ovro.caltech.edu>
	 <4A8B9051.3020505@redhat.com> <20090819152811.GA22294@ovro.caltech.edu>
	 <4A8C1C22.3010101@redhat.com> <20090819162902.GB22294@ovro.caltech.edu>
	 <4A8C2A87.5060305@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>,
	Stefan Hajnoczi <stefanha@gmail.com>
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A8C2A87.5060305@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-08-19 at 19:38 +0300, Avi Kivity wrote:
> On 08/19/2009 07:29 PM, Ira W. Snyder wrote:
> >
> >    
> >> virtio-$yourhardware or maybe virtio-dma
> >>
> >>      
> > How about virtio-phys?
> >    
> 
> Could work.
> 
> > Arnd and BenH are both looking at PPC systems (similar to mine). Grant
> > Likely is looking at talking to an processor core running on an FPGA,
> > IIRC. Most of the code can be shared, very little should need to be
> > board-specific, I hope.
> >    
> 
> Excellent.
> 
> >>> That said, I'm not sure how qemu-system-ppc running on x86 could
> >>> possibly communicate using virtio-net. This would mean the guest is an
> >>> emulated big-endian PPC, while the host is a little-endian x86. I
> >>> haven't actually tested this situation, so perhaps I am wrong.
> >>>
> >>>        
> >> I'm confused now.  You don't actually have any guest, do you, so why
> >> would you run qemu at all?
> >>
> >>      
> > I do not run qemu. I am just stating a problem with virtio-net that I
> > noticed. This is just so someone more knowledgeable can be aware of the
> > problem.
> >
> >    
> 
> Ah, it certainly doesn't byteswap.  Maybe nobody tried it.  Hollis?

I've never tried it. I've only used virtio with matching guest/host
architectures.

-- 
Hollis Blanchard
IBM Linux Technology Center

