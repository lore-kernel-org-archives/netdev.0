From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [1/4] kevent: core files.
Date: Fri, 23 Jun 2006 17:31:44 -0400
Message-ID: <20060623213144.GF14126@kvack.org>
References: <20060622171436.GA26161@2ka.mipt.ru> <20060623070933.GA20291@2ka.mipt.ru> <20060623184457.GA13617@kvack.org> <20060623192422.GA11508@2ka.mipt.ru> <20060623195513.GC14126@kvack.org> <20060623201716.GA26168@2ka.mipt.ru> <20060623204442.GE14126@kvack.org> <20060623210826.GC26168@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:43440 "EHLO kanga.kvack.org")
	by vger.kernel.org with ESMTP id S1752086AbWFWVcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 17:32:02 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060623210826.GC26168@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 24, 2006 at 01:08:27AM +0400, Evgeniy Polyakov wrote:
> On Fri, Jun 23, 2006 at 04:44:42PM -0400, Benjamin LaHaise (bcrl@kvack.org) wrote:
> > > AIO completion approach was designed to be used with process context VFS
> > > update. read/write approach can not cover other types of notifications,
> > > like inode updates or timers.
> > 
> > The completion event is 100% generic and does not need to come from process 
> > context.  Calling aio_complete() from irq context is entirely valid.
> 
> put_ioctx() can sleep.

Err, no, that should definately not be the case.  If it can, someone has 
completely broken aio.

> It is not syscall, but overall design should be analyzed.
> It is possible to use existing ssycalls, kevent design does not care
> about how it's data structures are delivered to the internal
> "processor".

Okay, that's good to hear. =-)

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.
