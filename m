From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: Route cache performance under stress
Date: Tue, 17 Jun 2003 22:58:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <87ptlc4e14.fsf@deneb.enyo.de>
References: <20030608234926.GA9453@netnation.com>
	<001001c32e19$81bc7ea0$4a00000a@badass>
	<20030609064719.GA20613@netnation.com>
	<Pine.LNX.4.51.0306090918400.11389@ns.istop.com>
	<20030609163010.GA11509@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ralph+d@istop.com, "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
   "linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20030609163010.GA11509@netnation.com> (Simon Kirby's message
 of "Mon, 9 Jun 2003 09:30:10 -0700")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Simon Kirby <sim@netnation.com> writes:

> What Zebra quirks?

Zebra doesn't send BGP keepalives while updating the kernel's view of
the routing table.  If a configuration change results massive routing
table updates (e.g. changed LOCAL_PREF), it's quite likely that you
BGP peering sessions terminate because of a timeout.

Other "quirks" are just things that don't work as they should (mostly
Cisco incompatibilities, sometimes genuine bugs in route-map support
etc.).

It's not dramatic in most cases, but like any complex technology, it
takes some time to get used to.

(Disclaimer: I'm not a Zebra user. 8-)

> And I wouldn't exactly call it difficult to "squeeze" performance out of
> a PC when the 7206 VXRs have a 200 MHz processor.

You missed the NPE-G1 part.

cisco 7204VXR (NPE-G1) processor (revision A) with 245760K/16384K bytes of memory.
SB-1 CPU at 700Mhz, Implementation 1, Rev 0.2, 512KB L2 Cache

Probably still slow by x86 standards, and with a rather small cache,
but it's sufficient for a few kpps, I guess...
