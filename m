From: jamal <hadi@cyberus.ca>
Subject: Re: bonding vs 802.3ad/Cisco EtherChannel link agregation
Date: Tue, 17 Sep 2002 06:16:51 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.GSO.4.30.0209170608510.1371-100000@shell.cyberus.ca>
References: <3D860246.3060609@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Chris Friesen <cfriesen@nortelnetworks.com>,
	Cacophonix <cacophonix@yahoo.com>, <linux-net@vger.kernel.org>,
	<netdev@oss.sgi.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3D860246.3060609@candelatech.com>
List-Id: netdev.vger.kernel.org



On Mon, 16 Sep 2002, Ben Greear wrote:

> Also, I notice lots of out-of-order packets on a single gigE link when running at high
> speeds (SMP machine), so the kernel is still having to reorder quite a few packets.
> Has anyone done any tests to see how much worse it is with dual-port bonding?

It will depend on the scheduling algorithm used.
Always remember that reordering is BAD for TCP and you shall be fine.
Typical for TCP you want to run a single flow onto a single NIC.
If you are running some UDP type control app in a cluster environment
where ordering is a non-issue then you could maximize throughput
by sending as fast as you can on all interfaces.

>
> NAPI helps my problem, but does not make it go away entirely.
>

Could you be more specific as to where you see reordering with NAPI?
Please dont disappear. What us it that you see that makes you believe
theres reordering with NAPI i.edescribe your test setup etc.

cheers,
jamal

