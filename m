From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take35 0/10] kevent: Generic event handling mechanism.
Date: Mon, 5 Feb 2007 17:23:36 +0300
Message-ID: <20070205142336.GA24190@2ka.mipt.ru>
References: <asdasdqaa0591036@2ka.mipt.ru> <11703247503374@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932860AbXBEO0p@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <11703247503374@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 01, 2007 at 01:12:30PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> 
> Generic event handling mechanism.
> 
> Kevent is a generic subsytem which allows to handle event notifications.
> It supports both level and edge triggered events. It is similar to
> poll/epoll in some cases, but it is more scalable, it is faster and
> allows to work with essentially eny kind of events.
> 
> Events are provided into kernel through control syscall and can be read
> back through ring buffer or using usual syscalls.
> Kevent update (i.e. readiness switching) happens directly from internals
> of the appropriate state machine of the underlying subsytem (like
> network, filesystem, timer or any other).
> 
> Homepage:
> http://tservice.net.ru/~s0mbre/old/?section=projects&item=kevent
> 
> Documentation page:
> http://linux-net.osdl.org/index.php/Kevent
> 
> Consider for inclusion.
> 
> P.S. If you want to be removed from Cc: list just drop me a mail.
> 
> Changes from 'take34' patchset:
>  * Ported to the 2.6.20-rc7 (9be5b038b1c9d1927c367bf91683458e10d5d4eb) tree.

Is there some progress?
Some things to be implemented, described or discussed?

Thank you.

-- 
	Evgeniy Polyakov
