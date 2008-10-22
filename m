From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] pkt_sched: sch_netem: Limit packet re-ordering
	functionality to tfifo qdisc.
Date: Wed, 22 Oct 2008 19:53:21 +0200
Message-ID: <20081022175321.GA2710@ami.dom.local>
References: <20081017130333.GA8297@ff.dom.local> <48F89D33.9090809@trash.net> <20081017201210.GA2527@ami.dom.local> <20081021.163605.57275028.davem@davemloft.net> <20081021165129.422dd83f@extreme> <20081022053746.GA4178@ff.dom.local> <48FF4E38.9010806@trash.net> <20081022164925.GB2556@ami.dom.local> <48FF6392.5000305@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:6202 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760791AbYJVRwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 13:52:43 -0400
Received: by ey-out-2122.google.com with SMTP id 6so1023686eyi.37
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2008 10:52:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48FF6392.5000305@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 22, 2008 at 07:32:02PM +0200, Patrick McHardy wrote:
...
> Well, you're doing the work, so you decide. I'm undecided myself,
> the main issues I see are:

Well, I've only tried to finish David's "Killing qdisc->ops->requeue()",
which I had broken before. Then somebody framed me into this ->peek()
/netem thing...

...
> So actually I am decided :) I think netem shouldn't be classful.

OK, I added RFC to the subject.

Jarek P.
