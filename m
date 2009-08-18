From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for
	vbus_driver objects
Date: Tue, 18 Aug 2009 19:51:39 +0300
Message-ID: <20090818165139.GC19846@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <4A89FF08.30509@codemonkey.ws> <4A8AA9BD.2070909@gmail.com> <4A8AB076.6080906@redhat.com> <4A8ACE1F.6020402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Avi Kivity <avi@redhat.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40542 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759359AbZHRQxS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2009 12:53:18 -0400
Content-Disposition: inline
In-Reply-To: <4A8ACE1F.6020402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 18, 2009 at 11:51:59AM -0400, Gregory Haskins wrote:
> > It's not laughably trivial when you try to support the full feature set
> > of kvm (for example, live migration will require dirty memory tracking,
> > and exporting all state stored in the kernel to userspace).
> 
> Doesn't vhost suffer from the same issue?  If not, could I also apply
> the same technique to support live-migration in vbus?

vhost does this by switching to userspace for the duration of live
migration. venet could do this I guess, but you'd need to write a
userspace implementation. vhost just reuses existing userspace virtio.

> With all due respect, I didnt ask you do to anything, especially not
> abandon something you are happy with.
> 
> All I did was push guest drivers to LKML.  The code in question is
> independent of KVM, and its proven to improve the experience of using
> Linux as a platform.  There are people interested in using them (by
> virtue of the number of people that have signed up for the AlacrityVM
> list, and have mailed me privately about this work).
> 
> So where is the problem here?

If virtio net in guest could be improved instead, everyone would
benefit. I am doing this, and I wish more people would join.  Instead,
you change ABI in a incompatible way. So now, there's no single place to
work on kvm networking performance. Now, it would all be understandable
if the reason was e.g. better performance. But you say yourself it
isn't. See the problem?

-- 
MST
