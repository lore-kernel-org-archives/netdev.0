From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] tilegx: fix some issues in the SW TSO support
Date: Thu, 25 Oct 2012 20:48:45 +0100
Message-ID: <1351194525.2662.21.camel@bwh-desktop.uk.solarflarecom.com>
References: <201210251737.q9PHbgev032681@farm-0012.internal.tilera.com>
	 <1351187513.2662.9.camel@bwh-desktop.uk.solarflarecom.com>
	 <508981E1.4030600@tilera.com>
	 <1351193806.2662.18.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1351193806.2662.18.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-10-25 at 20:36 +0100, Ben Hutchings wrote:
[...]
> There's a simple way to test this - configure the 'attacker' host and
> interface like this:
> 
> # ip link set $IFACE mtu 128
> # sysctl net.ipv4.route.min_adv_mss=88
> 
> and then use something like netperf to generate a high bandwidth stream
> of TCP traffic toward it from the tilegx interface.

Also you would need to run some other traffic in parallel (multiple
streams to the 'attacker' and some more normal streams) to ensure there
is real contention.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
