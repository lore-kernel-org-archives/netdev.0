From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2]: softirq: Add support for triggering softirq work
 on softirqs.
Date: Sat, 20 Sep 2008 13:03:25 -0700 (PDT)
Message-ID: <20080920.130325.56429707.davem@davemloft.net>
References: <20080919.234832.127229997.davem@davemloft.net>
	<1221925413.1343.132.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com, steffen.klassert@secunet.com
To: dwalker@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50399
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751266AbYITUDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 16:03:37 -0400
In-Reply-To: <1221925413.1343.132.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Walker <dwalker@mvista.com>
Date: Sat, 20 Sep 2008 08:43:33 -0700

> On Fri, 2008-09-19 at 23:48 -0700, David Miller wrote:
> 
> > @@ -6,6 +6,8 @@
> >   *	Distribute under GPLv2.
> >   *
> >   *	Rewritten. Old one was good in 2.2, but in 2.3 it was immoral. --ANK (990903)
> > + *
> > + *	Remote softirq infrastructure is by Jens Axboe.
> >   */
> 
> This goes in the GIT log so I hear, so you shouldn't need to add it to
> the top.. It sounds like your saying Jens is the author, but I'm sure
> you are..

No, Jens wrote this code, I just merely made it generic.
He also deserves a mention at the top of the file.  If
we had left it in the block layer, he would have received
such a mention.

Why the heck does this even bother you?

> This list your adding is rather confusing .. You add to it, but never
> remove anything.. You've got it in the header file, so you must use it
> someplace else .. Then I don't see what else it could be used for other
> than triggering the softirq..

The layers that use this stuff dequeue from their softirq
handler, directly from the list, that's why it's exported.

> This whole patch really needs ifdefs. There's no value here on UP, since
> what other cpu are you going to send softirqs to?

On UP we get a single queue, which the layer needs anyways.
It just always queues to the one queue.

Unlike Andrew's, your review comments have been completely and utterly
useless, as well as a total waste of my time.
