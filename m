From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [announce] iproute2 2.6.19-061214
Date: Wed, 31 Jan 2007 12:37:50 -0500
Message-ID: <45C0D3EE.4040605@tmr.com>
References: <20061214154627.78ff25c0@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org,
	lartc <lartc@mailman.ds9a.nl>
To: Stephen Hemminger <shemminger@osdl.org>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20061214154627.78ff25c0@freekitty>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This is an update to the iproute2 command set.
> It can be downloaded from:
>   http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.18-061214.tar.gz
>   

The 2.6.18 should be 2.6.19. Am I the first person to actually try that 
link?
> Repository:
>   git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git
>
> For more info on iproute2 see:
>   http://linux-net.osdl.org/index.php/Iproute2
>
> The version number includes the kernel version to denote what features are
> supported. The same source should build on older systems, but obviously the
> newer kernel features won't be available. As much as possible, this package
> tries to be source compatible across releases.
>
> Changes from 2.6.18-061002 to 2.6.19-061214:
>
> Boian Bonev:
>       Display local route table name correctly in output of:
>
> Hasso Tepper:
>       Fixes for tc help commands
>
> jamal:
>       Multicast computation off by one
>       Update generic netlink header
>       Add controller support for new features exposed
>       clarify "ok" and "pass"
>       Fix missing class/flowid oddity
>       Mention need for db dev package
>       update xfrm async events
>       make muticast group to bitmask conversion generic
>       update xfrm monitoring to use nl_mgrp
>
> Masahide NAKAMURA:
>       ADDR: Fix print format for lifetimes.
>       ADDR: Enable to add IPv6 address with valid/preferred lifetime.
>       ADDR: Define 0xFFFFFFFFU as INFINITY_LIFE_TIME regarding to the kernel.
>       TUNNEL: Split common functions to export them.
>       TUNNEL: Import ip6tunnel.c.
>       TUNNEL: IPv6-over-IPv6 tunnel support.
>       XFRM: sub policy support.
>       XFRM: Mobile IPv6 route optimization support.
>       XFRM: support report message by monitor.
>       XFRM: Mobility header support.
>
> Noriaki TAKAMIYA:
>       ADDR: Add the 'change' and 'replace' commands to the IPv6 address manipulation context.
>
> Patrick McHardy:
>       [IPROUTE]: Add support for routing rule fwmark masks
>
> Stephen Hemminger:
>       Man page for ss submitted by Alex Wirt
>       Typo in man page
>       Trap possible overflow in usec values to netem
>       genl Makefile LDFLAGS
>       SA and SP in IPSec BEET mode.
>       Route metrics decode bug.
>       lnstat man page
>       Man page for rtmon
>       Update to 2.6.19 headers
>       Add more includes
>       Change to post 2.6.19 sanitized headers
>       Eliminate trailing whitespace
>
>
> Thomas Graf:
>       Add support for inverted selectors
>       Add rule notification support to ip monitor
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>   


-- 
bill davidsen <davidsen@tmr.com>
  CTO TMR Associates, Inc
  Doing interesting things with small computers since 1979

