From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost-net: switch to smp barriers
Date: Sat, 13 Feb 2010 19:39:11 +0200
Message-ID: <20100213173911.GA5040@redhat.com>
References: <20100201172101.GA10900@redhat.com> <20100207090749.GA12968@redhat.com> <201002081849.39512.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201002081849.39512.rusty@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 08, 2010 at 06:49:39PM +1030, Rusty Russell wrote:
> On Sun, 7 Feb 2010 07:37:49 pm Michael S. Tsirkin wrote:
> > On Mon, Feb 01, 2010 at 07:21:02PM +0200, Michael S. Tsirkin wrote:
> > > vhost-net only uses memory barriers to control SMP effects
> > > (communication with userspace potentially running on a different CPU),
> > > so it should use SMP barriers and not mandatory barriers for memory
> > > access ordering, as suggested by Documentation/memory-barriers.txt
> > > 
> > > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > 
> > 
> > Rusty, any feedback on this one?
> > Thanks!
> 
> Yep.  barrier() is correct on UP to guard against preemption.
> 
> Acked-by: Rusty Russell <rusty@rustcorp.com.au>
> 
> Thanks,
> Rusty.

Dave, I see it's marked "not applicable":
http://patchwork.ozlabs.org/patch/44207/
the patch applies to net-next as of
b3b3f04fb587ecb61b5baa6c1c5f0e666fd12d73.
Can this be queued up please?
Should I resubmit with Rusty's ack?

Thanks!

-- 
MST
