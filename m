From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for
	vbus_driver objects
Date: Tue, 18 Aug 2009 19:39:34 +0300
Message-ID: <20090818163934.GB19846@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com> <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com> <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com> <20090818095313.GC13878@redhat.com> <4A8ACB2D.9060108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	Avi Kivity <avi@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759304AbZHRQlU@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A8ACB2D.9060108@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 18, 2009 at 11:39:25AM -0400, Gregory Haskins wrote:
> Michael S. Tsirkin wrote:
> > On Mon, Aug 17, 2009 at 03:33:30PM -0400, Gregory Haskins wrote:
> >> There is a secondary question of venet (a vbus native device) verses
> >> virtio-net (a virtio native device that works with PCI or VBUS).  If
> >> this contention is really around venet vs virtio-net, I may possibly
> >> conceed and retract its submission to mainline.
> > 
> > For me yes, venet+ioq competing with virtio+virtqueue.
> > 
> >> I've been pushing it to date because people are using it and I don't
> >> see any reason that the driver couldn't be upstream.
> > 
> > If virtio is just as fast, they can just use it without knowing it.
> > Clearly, that's better since we support virtio anyway ...
> 
> More specifically: kvm can support whatever it wants.  I am not asking
> kvm to support venet.
> 
> If we (the alacrityvm community) decide to keep maintaining venet, _we_
> will support it, and I have no problem with that.
> 
> As of right now, we are doing some interesting things with it in the lab
> and its certainly more flexible for us as a platform since we maintain
> the ABI and feature set. So for now, I do not think its a big deal if
> they both co-exist, and it has no bearing on KVM upstream.

As someone who extended them recently, both ABI and feature set with
virtio are pretty flexible.  What's the problem?  Will every single
contributor now push a driver with an incompatible ABI upstream because
this way he maintains both ABI and feature set? Oh well ...


-- 
MST
