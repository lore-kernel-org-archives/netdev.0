From: Mike Galbraith <efault@gmx.de>
Subject: Re: 2.6.23-rc1: BUG_ON in kmap_atomic_prot()
Date: Tue, 24 Jul 2007 12:37:48 +0200
Message-ID: <1185273468.6467.5.camel@Homer.simpson.net>
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org>
	 <20070723183839.GA5874@martell.zuzino.mipt.ru>
	 <20070723190152.GA5755@martell.zuzino.mipt.ru>
	 <20070723132431.42afbae8.akpm@linux-foundation.org>
	 <1185271269.6479.7.camel@Homer.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:46672 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S933443AbXGXKht (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 06:37:49 -0400
In-Reply-To: <1185271269.6479.7.camel@Homer.simpson.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-07-24 at 12:01 +0200, Mike Galbraith wrote:
> On Mon, 2007-07-23 at 13:24 -0700, Andrew Morton wrote:
> 
> > You're using DEBUG_PAGEALLOC, but I was not, so I think we can rule that out.
> 
> My box bugged during boot the first time I booted 23-rc1, but nothing
> made it to the console, and I didn't have a serial console running.  I
> didn't have DEBUG_PAGEALLOC or friends set.
> 
> > I haven't worked out where that kmap_atomic() call is coming from yet. 
> > Both traces point up into the page allocator, but I _think_ that's stack
> > gunk.
> 
> I just enabled all debug options, and was just rewarded with the below.

Hm.  I just also experienced filesystem corruption when I tried to send
from that kernel, and it bugged in the process.  My mount table ended up
in /etc/resolv.conf along with some binary goop, making nscd rather
unhappy after reboot.  fsck time.

	.Mike

