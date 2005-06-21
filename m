From: Andi Kleen <ak@suse.de>
Subject: Re: [patch] devinet: cleanup if statements
Date: 21 Jun 2005 23:51:11 +0200
Message-ID: <p73k6knbcq8.fsf@verdi.suse.de>
References: <200506072032.NAA06207@allur.sanmateo.akamai.com>
	<20050621.134822.21926602.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pmeda@akamai.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050621.134822.21926602.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@davemloft.net> writes:
> 
> This whole area is pretty messy, we should examine the true
> intended semantics of the ifa_label stuff.

Perhaps it would be best to just retire that 2.0 alias compatibility 
cruft now. Everybody should be using ifconfig or iproute2 by now
that can add or remove addresses directly without the compatibility
syntax.

They never worked fully in corner cases anyways, e.g. SIOCSIFNAME with
these aliases was always a problem.

-Andi
