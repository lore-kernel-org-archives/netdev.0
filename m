From: josh@joshtriplett.org
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 6 May 2014 13:27:19 -0700
Message-ID: <20140506202719.GD21332@cloud>
References: <1399328773-6531-9-git-send-email-andi@firstfloor.org>
 <20140505.231229.136734008603421707.davem@davemloft.net>
 <20140506032114.GP2382@two.firstfloor.org>
 <20140505.232327.578134514220748085.davem@davemloft.net>
 <20140506155703.GA20391@cloud>
 <1399394359.15399.20.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140506183216.GM19657@tassilo.jf.intel.com>
 <1399407478.15399.81.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@linux.intel.com>,
	David Miller <davem@davemloft.net>, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:51008 "EHLO
	relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517AbaEFU1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 16:27:23 -0400
Content-Disposition: inline
In-Reply-To: <1399407478.15399.81.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 06, 2014 at 01:17:58PM -0700, Eric Dumazet wrote:
> On Tue, 2014-05-06 at 11:32 -0700, Andi Kleen wrote:
> > > We simply can not compete with user space, as a programmer is free to
> > > keep what he really wants/needs.
> > 
> > Not true.
> 
> You can shake the kernel as much as you want, you wont make :
> - a TCP socket
> - a dentry
> - an inode
> - a file structure
> - eventpoll structures (assuming epoll use)
> - 2 dst per flow.
> 
> In 1024 bytes of memory, and keep an efficient kernel to handle
> arbitrary number of sockets using the venerable and slow BSD socket api.
> 
> I was objecting to the "crazy things like LWIP" comment from Josh, not
> to your patches in general.

My primary statement was that it's crazy to use something like LWIP just
because you want a *tiny* system.  We could argue about using LWIP
because you want a massively scalable system, or one that more closely
couples userspace and the kernel, but that's not the current goal in any
case.  So let's drop that branch of the thread. :)

> I actually took a look at them but stopped at patch 22
> 
> Adding ~1000 lines of code to save few KB was the point I gave up.

Please consider ignoring that one and reading the rest; we could always
handle the routing table issue separately.

- Josh Triplett
