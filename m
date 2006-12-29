From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take29 0/8] kevent: Generic event handling mechanism.
Date: Fri, 29 Dec 2006 11:55:04 +0300
Message-ID: <20061229085503.GB13816@2ka.mipt.ru>
References: <3154985aa0591036@2ka.mipt.ru> <11668927001365@2ka.mipt.ru> <20061228160137.GA19301@elte.hu>
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
	Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:40900 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965051AbWL2Jfy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Dec 2006 04:35:54 -0500
To: Ingo Molnar <mingo@elte.hu>
Content-Disposition: inline
In-Reply-To: <20061228160137.GA19301@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 28, 2006 at 05:01:37PM +0100, Ingo Molnar (mingo@elte.hu) wrote:
> 
> * Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> 
> > Generic event handling mechanism.
> 
> i see it covers alot of event sources, but i cannot see block IO 
> notifications. Am i missing something?

Depending on what it is :)
If you mean kevent based AIO, then it was dropped to reduce size of the
patchset, and in favour of new AIO design.
Other kinds of read/write notifications can be handled by poll/select
notifications.

> 	Ingo

-- 
	Evgeniy Polyakov
