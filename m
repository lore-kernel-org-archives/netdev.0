From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: Route cache performance under stress
Date: Mon, 26 May 2003 09:18:19 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <87adda6uro.fsf@deneb.enyo.de>
References: <Pine.LNX.4.51.0305191408490.1795@ns.istop.com>
	<20030519154852.I39024@shell.cyberus.ca>
	<20030520011053.GB10419@netnation.com>
	<20030519.181405.35017608.davem@redhat.com>
	<20030519212209.P39592@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Jamal Hadi <hadi@shell.cyberus.ca>
In-Reply-To: <20030519212209.P39592@shell.cyberus.ca> (Jamal Hadi's message
 of "Mon, 19 May 2003 21:23:08 -0400 (EDT)")
List-Id: netdev.vger.kernel.org

Jamal Hadi <hadi@shell.cyberus.ca> writes:

> Also used to attack CISCOs by them kiddies btw. We stand much better
> than any CISCO doing caching.

Cisco IOS doesn't have this hash collisions problem, they have moved
away from hash tables ages ago.  You are probably just seeing CPU
starvation (Cisco routers aren't equipped with the fastest available
CPUs *sigh*, and you lose if routing is not performed by other means).

BTW, CEF is just a marketing term.  There's a plethora of
implementations, ranging from software-only to ASICs to special memory
chips (associative arrays with wildcards).  These implementations have
vastly different implications for router performance.  Most notably,
CEF is not a cache (not even in the software case), the data structure
are changed when updated routing information is encountered and not
when packets are received which need to be routed.
