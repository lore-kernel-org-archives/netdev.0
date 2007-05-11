From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [RFC] make qdisc_restart more readable
Date: Fri, 11 May 2007 11:46:42 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902D42586@orsmsx414.amr.corp.intel.com>
References: <1178908559.4126.19.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28989 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757865AbXEKSqn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 14:46:43 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1178908559.4126.19.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> For lockless drivers, I think it could be moved up; only 
> thing is nothing is stopping it from changing again at transmit time.
> For drivers that are not lockless, i am wondering if its even 
> useful to have that check given we have already grabbed the tx lock.

Good point.  I live in an LLTX world, so I don't think tx_lock mode very
often.

> 
> >   That
> > way you still hold dev->queue_lock in case the queue is 
> stopped, and 
> > haven't yet pulled an skb causing a requeue event.
> 
> It certainly sounds like a useful optimization. Defer that 
> thought - for now i just want to make sure its doing what the 
> previous code did.

Agreed.

> 
> I will repost the fixed patch later today after some testing; 
> if you have time i will appreciate some eyeballing. That 
> piece of code is hairy. Hopefully we can make it bald.

Clippers are standing by.  :)

-PJ
