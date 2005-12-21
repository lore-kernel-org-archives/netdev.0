From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFC][PATCH 0/3] TCP/IP Critical socket communication mechanism
Date: Wed, 21 Dec 2005 01:39:14 -0800
Message-ID: <OF64F635C2.05062E9D-ON882570DE.0034368A-882570DE.0034EEAA@us.ibm.com>
References: <20051221091114.GA8495@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: ak@suse.de, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, mpm@selenic.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>, sri@us.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932337AbVLUJiP@vger.kernel.org>
In-Reply-To: <20051221091114.GA8495@elf.ucw.cz>
To: Pavel Machek <pavel@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Why not do it the other way? "If you don't hear from me for 2 minutes,
> do a switchover". Then all you have to do is _not_ to send a packet --
> easier to do.
> 
> Anything else seems overkill.
>                         Pavel

        Because in some of the scenarios, including ours, it isn't a
simple failover to a known alternate device or configuration --
it is reconfiguring dynamically with information received on a
socket from a remote machine (while the swap device is unavailable).
        Limited socket communication without allocating new memory
that may not be available is the problem definition. Avoiding the
problem in the first place (your solution) is effective if you
can do it, of course. The trick is to solve the problem when you
can't avoid it. :-)

                                                        +-DLS
