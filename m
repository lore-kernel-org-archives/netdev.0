From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Mon, 27 Oct 2008 14:42:55 +0100 (CET)
Message-ID: <alpine.LNX.1.10.0810271441590.12928@jikos.suse.cz>
References: <20081024.221653.23695396.davem@davemloft.net>  <1224914333.3822.18.camel@marge.simson.net>  <1224917623.4929.15.camel@marge.simson.net>  <20081025.002420.82739316.davem@davemloft.net>  <Pine.LNX.4.64.0810260055070.22126@twin.jikos.cz>
 <1225010790.8566.22.camel@marge.simson.net>  <1225011648.27415.4.camel@twins>  <20081026021153.47878580.akpm@linux-foundation.org>  <alpine.LNX.1.10.0810262002450.12928@jikos.suse.cz>  <alpine.LNX.1.10.0810271138470.12928@jikos.suse.cz>  <20081027112750.GA2771@elte.hu>
  <20081027113306.5b1d5898@lxorguk.ukuu.org.uk> <1225109171.4238.23.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	David Miller <davem@davemloft.net>, rjw@sisk.pl,
	s0mbre@tservice.net.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Mike Galbraith <efault@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:59220 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751501AbYJ0Nm4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 09:42:56 -0400
In-Reply-To: <1225109171.4238.23.camel@marge.simson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Oct 2008, Mike Galbraith wrote:

> > real world workloads. If your fairness hurts throughput that much maybe
> > your scheduler algorithm is just plain *wrong* as it isn't adapting to
> > workload at all well.
> Doesn't seem to be scheduler/fairness.  2.6.22.19 is O(1), and falls
> apart too, I posted the numbers and full dbench output yesterday.

We'll need to look into this a little bit more I think. I have sent out 
some numbers too, and these indicate very clearly that there is more than 
50% performance drop (measured by dbench) just after the very merge of CFS 
in 2.6.23-rc1 merge window.

-- 
Jiri Kosina
SUSE Labs
