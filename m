From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take15 4/4] kevent: Timer notifications.
Date: Wed, 6 Sep 2006 10:42:46 +0400
Message-ID: <20060906064245.GA28825@2ka.mipt.ru>
References: <11573648632380@2ka.mipt.ru> <200609051539.58492.arnd.bergmann@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:16867 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750750AbWIFGn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 02:43:28 -0400
To: Arnd Bergmann <arnd.bergmann@de.ibm.com>
Content-Disposition: inline
In-Reply-To: <200609051539.58492.arnd.bergmann@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 05, 2006 at 03:39:57PM +0200, Arnd Bergmann (arnd.bergmann@de.ibm.com) wrote:
> On Monday 04 September 2006 12:14, Evgeniy Polyakov wrote:
> > Timer notifications can be used for fine grained per-process time 
> > management, since interval timers are very inconvenient to use, 
> > and they are limited.
> 
> I guess this must have been discussed before, but why is this
> not using high-resolution timers?
> 
> Are you planning to change this?
> 
> Maybe at least mention it in the description.

I can use them, but right now there is no strong requirement for that.
It is in TODO, but not at the top.
The most important thing right now is kevent core.

> 	Arnd <><

-- 
	Evgeniy Polyakov
