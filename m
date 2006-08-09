From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take6 0/3] kevent: Generic event handling mechanism.
Date: Wed, 9 Aug 2006 12:07:57 +0400
Message-ID: <20060809080754.GA29783@2ka.mipt.ru>
References: <20060731103322.GA1898@2ka.mipt.ru> <11551105592821@2ka.mipt.ru> <20060809.005856.104034268.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: linux-kernel@vger.kernel.org, drepper@redhat.com,
	netdev@vger.kernel.org, zach.brown@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:14761 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S965088AbWHIIJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 04:09:11 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060809.005856.104034268.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2006 at 12:58:56AM -0700, David Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Wed, 9 Aug 2006 12:02:39 +0400
> 
> Evgeniy, it's things like the following that make it very draining
> mentally to review your work.
> 
> >  * removed AIO stuff from patchset
> 
> You didn't really do this, you leave the aio_* syscalls and stubs in
> there, and you also left things like tcp_async_send() in there.

By AIO I meant VFS AIO, not network stuff, exactly that part was frown 
upon in reviews.

> All the foo_naio_*() stuff is still in there to.
> 
> Please remove all of async business we've asked you to.

So you want to review kevent core only at the first point and postpone
network AIO and the rest implementation after core is correct.
Should I remove poll/timer notifications too?

-- 
	Evgeniy Polyakov
