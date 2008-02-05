From: Ross Vandegrift <ross@kallisti.us>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Tue, 5 Feb 2008 16:23:35 -0500
Message-ID: <20080205212335.GA11287@kallisti.us>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com> <20080205155558.GA23145@one.firstfloor.org> <c9e534200802051029u5d08cf6dm54866f769e362262@mail.gmail.com> <20080205192559.GA10573@kallisti.us> <20080205201106.GB26150@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Glenn Griffin <ggriffin.kernel@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kallisti.us ([67.59.168.233]:51539 "EHLO kallisti.us"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755585AbYBEVXm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 16:23:42 -0500
Content-Disposition: inline
In-Reply-To: <20080205201106.GB26150@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 05, 2008 at 09:11:06PM +0100, Andi Kleen wrote:
> > The problem is that any reasonably recent PC can generate enough
> > forged SYN packets to overwhelm reasonable SYN queues on a much more
> > powerful server.
> 
> Have you actually seen this with a recent kernel in the wild or are
> you just talking theoretically?
> 
> Linux uses some heuristics to manage the syn queue that should
> still ensure reasonable service even without cookies under attack.
> Also SYN-RECV sockets are stored in a special data structure optimized
> to use minimal resources.
> 
> It is far from the classical head drop method that was so vunerable
> to syn flooding.

I work at a hosting company and we see these kinds of issues in the
real world fairly frequently.  I would guess maybe a monthly basis.
The servers where we have seen this are typically running RHEL 4 or 5
kernels, so I can't really speak to how recent the kernel is in this
specific term.

If I can find a box that we could temporary get a kernel.org kernel
on, I'll see if I can get a real comparison together.  We have
collected a few of the more effective attack tools that have been left
on compromised systems, so it wouldn't be too difficult to get some
numbers.

-- 
Ross Vandegrift
ross@kallisti.us

"The good Christian should beware of mathematicians, and all those who
make empty prophecies. The danger already exists that the mathematicians
have made a covenant with the devil to darken the spirit and to confine
man in the bonds of Hell."
	--St. Augustine, De Genesi ad Litteram, Book II, xviii, 37
