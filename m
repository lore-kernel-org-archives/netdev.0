From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][NET_SCHED] explict hold dev tx lock
Date: Wed, 19 Sep 2007 09:09:37 -0700 (PDT)
Message-ID: <20070919.090937.32177545.davem@davemloft.net>
References: <20070917.190133.79431533.davem@davemloft.net>
	<1190083728.4237.59.camel@localhost>
	<1190208832.4259.6.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net, dada1@cosmosbay.com, johnpol@2ka.mipt.ru
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60638
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752124AbXISQJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 12:09:53 -0400
In-Reply-To: <1190208832.4259.6.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Wed, 19 Sep 2007 09:33:52 -0400

> On Mon, 2007-17-09 at 22:48 -0400, jamal wrote:
> 
> > Nothing much has changed from what it was before.
> > The only difference is we let go of the queue lock before grabbing
> > the tx lock which never mattered for LLTX. 
> > Once we grab the tx lock it is the same logic and so far is working well
> > on both tg3 and e1000 (which is LLTX). 
> > I will continue to retest with net-2.6.24 once you complete rebasing
> > and look around to see if anyone maybe affected.
> 
> Ok, this is looking solid with this mornings tree. Tested on a dual core
> xeon with e1000 (LLTX) and a dual core opteron with tg3 (non-LLTX).
> About 100 million packets from udp full throttle on all 4 cpus; i tried
> pulling cables etc while doing this to generate extrenous interupts and
> didnt see any issues.
> 
> Shall i submit the patch?

Sure, along with a description as to why you want to make this
change.

I still don't understand the impetus. :)
