From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 0/2] make mac programming for virtio net more robust
Date: Fri, 11 Jan 2013 09:46:24 +0200
Message-ID: <20130111074624.GB13315@redhat.com>
References: <1357829141-25455-1-git-send-email-akong@redhat.com>
 <20130110152829.GG30731@redhat.com>
 <87fw281mr8.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akong@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, qemu-devel@nongnu.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52442 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753456Ab3AKHmj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 02:42:39 -0500
Content-Disposition: inline
In-Reply-To: <87fw281mr8.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 11, 2013 at 12:53:07PM +1030, Rusty Russell wrote:
> "Michael S. Tsirkin" <mst@redhat.com> writes:
> 
> > On Thu, Jan 10, 2013 at 10:45:39PM +0800, akong@redhat.com wrote:
> >> From: Amos Kong <akong@redhat.com>
> >> 
> >> Currenly mac is programmed byte by byte. This means that we
> >> have an intermediate step where mac is wrong. 
> >> 
> >> Second patch introduced a new vq control command to set mac
> >> address in one time.
> >
> > As you mention we could alternatively do it without
> > new commands, simply add a feature bit that says that MACs are
> > in the mac table.
> > This would be a much bigger patch, and I'm fine with either way.
> > Rusty what do you think?
> 
> Hmm, mac filtering and "my mac address" are not quite the same thing.  I
> don't know if it matters for anyone: does it?
> The mac address is abused
> for things like identifying machines, etc.

I don't know either. I think net core differentiates between mac and
uc_list because linux has to know which mac to use when building
up packets, so at some level, I agree it might be useful to identify the
machine.

BTW netdev/davem should have been copied on this, Amos I think it's a
good idea to remember to do it next time you post.

> 
> If we keep it as a separate concept, Amos' patch seems to make sense.

Yes. It also keeps the patch small, I just thought I'd mention the
option.

> 
> Cheers,
> Rusty.

-- 
MST
