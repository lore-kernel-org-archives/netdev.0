From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take22 0/4] kevent: Generic event handling mechanism.
Date: Wed, 1 Nov 2006 16:25:07 +0300
Message-ID: <20061101132506.GA6433@2ka.mipt.ru>
References: <1154985aa0591036@2ka.mipt.ru> <1162380963981@2ka.mipt.ru> <20061101130614.GB7195@atrey.karlin.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer.campus.mipt.ru ([194.85.82.4]:57543 "EHLO
	mailer.campus.mipt.ru") by vger.kernel.org with ESMTP
	id S1750906AbWKANuS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Nov 2006 08:50:18 -0500
To: Pavel Machek <pavel@ucw.cz>
Content-Disposition: inline
In-Reply-To: <20061101130614.GB7195@atrey.karlin.mff.cuni.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 01, 2006 at 02:06:14PM +0100, Pavel Machek (pavel@ucw.cz) wrote:
> Hi!
> 
> > Generic event handling mechanism.
> > 
> > Consider for inclusion.
> > 
> > Changes from 'take21' patchset:
> 
> We are not interrested in how many times you spammed us, nor we want
> to know what was wrong in previous versions. It would be nice to have
> short summary of what this is good for, instead.

Let me guess, short explaination in subsequent emails is not enough...
If changelog will be removed, then how people will detect what happend 
after previous release?

Kevent is a generic subsytem which allows to handle event notifications.
It supports both level and edge triggered events. It is similar to
poll/epoll in some cases, but it is more scalable, it is faster and
allows to work with essentially eny kind of events.

Events are provided into kernel through control syscall and can be read
back through mmaped ring or syscall.
Kevent update (i.e. readiness switching) happens directly from internals
of the appropriate state machine of the underlying subsytem (like
network, filesystem, timer or any other).

I will put that text into introduction message.

> 								Pavel
> -- 
> Thanks, Sharp!

-- 
	Evgeniy Polyakov
