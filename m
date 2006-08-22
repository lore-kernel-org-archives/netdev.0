From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take12 0/3] kevent: Generic event handling mechanism.
Date: Tue, 22 Aug 2006 22:01:35 +0400
Message-ID: <20060822180135.GA30142@2ka.mipt.ru>
References: <11561555871530@2ka.mipt.ru> <1156230051.8055.27.camel@entropy> <20060822072448.GA5126@2ka.mipt.ru> <1156234672.8055.51.camel@entropy> <b3f268590608220957g43a16d6bmde8a542f8ad8710b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Nicholas Miell <nmiell@comcast.net>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:27317 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932329AbWHVSCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 14:02:39 -0400
To: Jari Sundell <sundell.software@gmail.com>
Content-Disposition: inline
In-Reply-To: <b3f268590608220957g43a16d6bmde8a542f8ad8710b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 22, 2006 at 06:57:05PM +0200, Jari Sundell (sundell.software@gmail.com) wrote:
> On 8/22/06, Nicholas Miell <nmiell@comcast.net> wrote:
> >
> >
> >OK, so with literally a dozen different interfaces to queue events to
> >userspace, all of which are apparently inadequate and in need of
> >replacement by kevent, don't you want to slow down a bit and make sure
> >that the kevent API is correct before it becomes permanent and then just
> >has to be replaced *again* ?
> >
> 
> Not to mention the name used causes (at least me) some confusion with BSD's
> kqueue implementation. Skimming over the patches it actually looks somewhat
> like kqueue with the more interesting features removed, like the ability to
> pass the filter changes simultaneously with polling.

I do not understand, what do you mean?
It is obviously allowed to poll and change kevents at the same time.

> Maybe this is a topic that will singe my fur, but what is wrong with the
> kqueue API? Will I really have to implement support for yet another event
> API in my program.

Why did I not implemented it like Solaris did?
Or FreeBSD did?
It was designed with features mention on AIO homepage in mind, but not
to be compatible with some other implementation.
And why should it be?

> Rakshasa

-- 
	Evgeniy Polyakov
