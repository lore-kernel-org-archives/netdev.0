From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: b44: timeout on initialization
Date: Fri, 14 Jan 2005 11:22:04 +0100
Message-ID: <20050114102204.GB3626@xi.wantstofly.org>
References: <20050113183147.0772941c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Florian Schirmer <jolt@tuxbox.org>
Content-Disposition: inline
In-Reply-To: <20050113183147.0772941c.shemminger@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 13, 2005 at 06:31:47PM -0800, Stephen Hemminger wrote:

> I get this all the time on my laptop (2.6.8 - 2.6.10) even
> when connected to the router
> b44: eth0: BUG!  Timeout waiting for bit 00000001 of register 41c to set.

I get a similar-looking message on my Dell Inspiron 8500 on 2.6.9:

	b44: eth0: BUG!  Timeout waiting for bit 80000000 of register 428 to clear.

This happens when UP'ing the device, both when at-the-time-of-UP'ing
already connected to some Cisco Catalyst that's configured to do only
10Mbps and no autonegotiation, as well as when not connected to anything
at all.  Not sure whether it also happens on 100Mbps or when using
autonegotiation -- can't check right now.

02:00.0 Ethernet controller: Broadcom Corporation BCM4401 100Base-T (rev 01)
	Subsystem: Dell: Unknown device 8127
	Flags: bus master, fast devsel, latency 32, IRQ 11
	Memory at faffe000 (32-bit, non-prefetchable) [size=8K]
	Capabilities: [40] Power Management version 2

Hope this helps.


--L
