From: David Miller <davem@davemloft.net>
Subject: Re: high latency with TCP connections
Date: Fri, 01 Sep 2006 02:49:35 -0700 (PDT)
Message-ID: <20060901.024935.71090427.davem@davemloft.net>
References: <20060831232923.GA10036@ms2.inr.ac.ru>
	<20060831.165701.104033558.davem@davemloft.net>
	<Pine.LNX.4.64.0609011241470.20878@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:31664
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751376AbWIAJtg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 05:49:36 -0400
To: pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.64.0609011241470.20878@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pekka Savola <pekkas@netcore.fi>
Date: Fri, 1 Sep 2006 12:44:48 +0300 (EEST)

> On Thu, 31 Aug 2006, David Miller wrote:
> ...
> >> Probably, aspect 1 of ABC just should be disabled. And the first my
> >> suggestion looks working too.
> >
> > I'm ready to rip out ABC entirely, to be honest.  Or at least
> > turn it off by default.
> 
> Just as a curious observer:  do you think these issues are due to ABC 
> implementation, or due to ABC specification?

It simply doesn't apply to us, as Alexey explained, because we prevent
ACK divison already when we apply the ACK to the retransmit queue
purging loop.  If we didn't free any whole packets, we don't advance
the congestion window.

The other bit, dealing with delayed ACKs, we could handle another
way.

ABC is a very BSD specific algorithm, as Alexey also mentioned.

