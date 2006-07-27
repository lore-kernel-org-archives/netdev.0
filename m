From: Jens Axboe <axboe@suse.de>
Subject: Re: async network I/O, event channels, etc
Date: Thu, 27 Jul 2006 10:09:02 +0200
Message-ID: <20060727080901.GG5282@suse.de>
References: <20060726062817.GA20636@2ka.mipt.ru> <20060726.231055.121220029.davem@davemloft.net> <20060727074902.GC5490@2ka.mipt.ru> <20060727.010255.87351515.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnpol@2ka.mipt.ru, drepper@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.virtualhost.dk ([195.184.98.160]:39976 "EHLO virtualhost.dk")
	by vger.kernel.org with ESMTP id S932236AbWG0IJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 04:09:22 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060727.010255.87351515.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 27 2006, David Miller wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Thu, 27 Jul 2006 11:49:02 +0400
> 
> > I.e. map skb's data to userspace? Not a good idea especially with it's
> > tricky lifetime and unability for userspace to inform kernel when it
> > finished and skb can be freed (without additional syscall).
> 
> Hmmm...
> 
> If it is paged based, I do not see the problem.  Events and calls to
> AIO I/O routines make transfer of buffer ownership.  The fact that
> while kernel (and thus networking stack) "owns" the buffer for an AIO
> call, the user can have a valid mapping to it is a unimportant detail.

Ownership may be clear, but "when can I reuse" is tricky. The same issue
comes up for vmsplice -> splice to socket.

-- 
Jens Axboe

