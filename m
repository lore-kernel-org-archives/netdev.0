From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take19 0/4] kevent: Generic event handling mechanism.
Date: Sat, 23 Sep 2006 08:23:50 +0400
Message-ID: <20060923042350.GA24099@2ka.mipt.ru>
References: <115a6230591036@2ka.mipt.ru> <11587449471424@2ka.mipt.ru> <20060922122207.3b716028.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:47250 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750807AbWIWE0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2006 00:26:12 -0400
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060922122207.3b716028.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 22, 2006 at 12:22:07PM -0700, Andrew Morton (akpm@osdl.org) wrote:
> On Wed, 20 Sep 2006 13:35:47 +0400
> Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> 
> > Generic event handling mechanism.
> > 
> > Consider for inclusion.
> 
> Ulrich's objections sounded substantial, and afaik remain largely
> unresolved.   How do we sort this out?

There are no objections, but request for additional interface.

The only two things missed in patchset after his suggestions are
new POSIX-like interface, which I personally consider as very unconvenient,
but in any way it can be implemented as addon, and signal mask change,
but Ulrich have not answered how does it differ from blocking in
userspace and then calling appropriate syscall, I expect the difference
is only in reduced number of syscalls.

-- 
	Evgeniy Polyakov
