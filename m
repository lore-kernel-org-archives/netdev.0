From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v5] bridge: multicast to unicast
Date: Tue, 24 Jan 2017 12:41:19 -0500 (EST)
Message-ID: <20170124.124119.2246238373876916746.davem@davemloft.net>
References: <20170121200133.1864-1-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, nbd-Vt+b4OUoWG0@public.gmane.org,
        nikolay-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170121200133.1864-1-linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Linus Lüssing <linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org>
Date: Sat, 21 Jan 2017 21:01:32 +0100

> From: Felix Fietkau <nbd-Vt+b4OUoWG0@public.gmane.org>
> 
> Implements an optional, per bridge port flag and feature to deliver
> multicast packets to any host on the according port via unicast
> individually. This is done by copying the packet per host and
> changing the multicast destination MAC to a unicast one accordingly.
> 
> multicast-to-unicast works on top of the multicast snooping feature of
> the bridge. Which means unicast copies are only delivered to hosts which
> are interested in it and signalized this via IGMP/MLD reports
> previously.
> 
> This feature is intended for interface types which have a more reliable
> and/or efficient way to deliver unicast packets than broadcast ones
> (e.g. wifi).
> 
> However, it should only be enabled on interfaces where no IGMPv2/MLDv1
> report suppression takes place. This feature is disabled by default.
> 
> The initial patch and idea is from Felix Fietkau.
> 
> Signed-off-by: Felix Fietkau <nbd-Vt+b4OUoWG0@public.gmane.org>
> [linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org: various bug + style fixes, commit message]
> Signed-off-by: Linus Lüssing <linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org>

I'm not completely happy that things have progressed this way, however
I don't have a better solution to suggest.
