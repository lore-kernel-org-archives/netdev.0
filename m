From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] netem: fix rate extension and drop accounting
Date: Wed, 4 Jul 2012 19:30:00 +0200
Message-ID: <20120704173000.GC3455@nuttenaction>
References: <1341307524.2583.115.camel@edumazet-glaptop>
 <1341309257.2583.153.camel@edumazet-glaptop>
 <20120703220442.GC5064@nuttenaction>
 <1341381488.2583.1395.camel@edumazet-glaptop>
 <20120704165132.GA3455@nuttenaction>
 <1341422601.2583.2393.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Andreas Terzis <aterzis@google.com>,
	Mark Gordon <msg@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:52855 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750839Ab2GDRaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 13:30:02 -0400
Content-Disposition: inline
In-Reply-To: <1341422601.2583.2393.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet | 2012-07-04 19:23:21 [+0200]:

>I fear you did your tests with no delay on netem.
>
>Try to setup a rate of 100kbit and a delay of 100ms and to really get
>full bandwith (100kbit), I am afraid it doesnt work.
>
>Your algo is OK only if no packets are in queue (obviously)
>
>But if you have 2 or 3 packets, the delay are cumulative,
>but the delay should be a fixed bias for each packet.

Right, we did not test it with delay because we emulated satelite links.
Static delay was negligible. All delay was caused by a limited rate. ok, I
will look at this!
