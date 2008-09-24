From: David Miller <davem@davemloft.net>
Subject: Re: AIM9 regression
Date: Tue, 23 Sep 2008 22:18:31 -0700 (PDT)
Message-ID: <20080923.221831.126801015.davem@davemloft.net>
References: <48D93203.2050204@linux-foundation.org>
	<20080924051237.GA6173@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47615
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751514AbYIXFSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 01:18:43 -0400
In-Reply-To: <20080924051237.GA6173@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 24 Sep 2008 13:12:37 +0800

> On Tue, Sep 23, 2008 at 01:14:27PM -0500, Christoph Lameter wrote:
> > I just dont seem to be able to get 2.6.27 to behave in a speedy way network
> > wise. Configured out various components (netfilter, etc etc) but I still keep
> > getting these aim9 result against 2.6.22:
> 
> Could you please compare this against something less ancient,
> like 2.6.26 perhaps?

Herbert, this is part of the tbench regression issues.  Christoph
took tbench from 2.6.22 until 2.6.27 and at basically every release
tbench performance suffered noticably.

Now, he's taking the AIM9 benchmark networking numbers and showing
that the same exact effect is seen there too.

It really behooves us to start doing something proactive about this
blindingly obvious set of networking performance regressions through
the past 6 or so releases instead of barking at the reporters saying
things like "try this, try that, what's your config" etc.

:-)
