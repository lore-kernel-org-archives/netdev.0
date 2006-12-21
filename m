From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [take28-resend_1->0 0/8] kevent: Generic event handling mechanism.
Date: Thu, 21 Dec 2006 05:41:41 -0500
Message-ID: <458A64E5.4050703@garzik.org>
References: <3154985aa0591036@2ka.mipt.ru> <11666924573643@2ka.mipt.ru> <20061221103539.GA4099@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41456 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965195AbWLUKlr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Dec 2006 05:41:47 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061221103539.GA4099@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Thu, Dec 21, 2006 at 12:14:17PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
>> Generic event handling mechanism.
>>
>> Kevent is a generic subsytem which allows to handle event notifications.
>> It supports both level and edge triggered events. It is similar to
>> poll/epoll in some cases, but it is more scalable, it is faster and
>> allows to work with essentially eny kind of events.
>>
>> Events are provided into kernel through control syscall and can be read
>> back through ring buffer or using usual syscalls.
>> Kevent update (i.e. readiness switching) happens directly from internals
>> of the appropriate state machine of the underlying subsytem (like
>> network, filesystem, timer or any other).
>>
>> Homepage:
>> http://tservice.net.ru/~s0mbre/old/?section=projects&item=kevent
>>
>> Documentation page:
>> http://linux-net.osdl.org/index.php/Kevent
>>
>> Consider for inclusion.
> 
> Due to this stall kevent inclusion into lighttpd CVS tree is postponed.
> 
> The last version will be released saturday or sunday, and looking into
> overhelming flow of feedback comments on this feature, project will not
> be released to linux-kernel@, after this I will
> complete netchannels support and start kevent based AIO project - mostly
> network AIO with new design, which is based on set of entities, which
> can describe set of tasks which should be performed
> asynchronously (from user point of view, although read and write
> obviously must be done after open and before close), for example syscall

kevent is being considered for inclusion, but there is no need to get 
impatient.  Once kevent code stops getting revised rapidly, Andrew 
Morton can pick it up for -mm, for wide dissemination, testing and 
review.  After that phase, it can be pushed to mainline.

The feeling I get from other kernel hackers is that you are demanding 
inclusion "now! now! now!" rather than giving all stakeholders a chance 
to give input, and let your design sink into the collective brain.

This isn't just an optional feature but a key new addition to the 
kernel.  So we should intentionally take more time and consideration 
than normal.  We don't want to go back and have to change fundamental 
kevent details due to design flaws, we want to get it right.

	Jeff



