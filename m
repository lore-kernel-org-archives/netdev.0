From: Nicholas Miell <nmiell@comcast.net>
Subject: Re: [take12 0/3] kevent: Generic event handling mechanism.
Date: Tue, 22 Aug 2006 01:59:51 -0700
Message-ID: <1156237191.8055.59.camel@entropy>
References: <1156230051.8055.27.camel@entropy>
	 <20060822072448.GA5126@2ka.mipt.ru> <1156234672.8055.51.camel@entropy>
	 <20060822.012341.57449506.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, linux-kernel@vger.kernel.org,
	drepper@redhat.com, akpm@osdl.org, netdev@vger.kernel.org,
	zach.brown@oracle.com, hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rwcrmhc12.comcast.net ([204.127.192.82]:63655 "EHLO
	rwcrmhc12.comcast.net") by vger.kernel.org with ESMTP
	id S932140AbWHVJAN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 05:00:13 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060822.012341.57449506.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-22 at 01:23 -0700, David Miller wrote:
> From: Nicholas Miell <nmiell@comcast.net>
> Date: Tue, 22 Aug 2006 01:17:52 -0700
> 
> > Is any of this documented anywhere? I'd think that any new userspace
> > interfaces should have man pages explaining their use and some example
> > code before getting merged into the kernel to shake out any interface
> > problems.
> 
> Get real.
> 
> Nobody made this requirement for things like splice() et al.
> 
> I think people are being mostly very unreasonable in the
> demands they are making upon Evgeniy.  It will only serve
> to discourage the one person who is doing work to solve
> these problems.

splice() is a single synchronous function call, and it's signature still
managed to change wildly during it's development.

In this brave new world of always stable kernel development, the time a
new interface has for public testing before a new kernel release is
drastically shorter than the old unstable development series, and if
nobody is documenting how this stuff is supposed to work and
demonstrating how it will be used, then mistakes are bound to slip
through.

-- 
Nicholas Miell <nmiell@comcast.net>

