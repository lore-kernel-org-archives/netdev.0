From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 ethernet bonding problems
Date: Sat, 28 Apr 2007 00:09:18 +0200
Message-ID: <20070427220918.GB24358@electric-eye.fr.zoreil.com>
References: <9e246b4d0704180552q16b05017wd0d7041c3ce04f46@mail.gmail.com> <20070418181333.GA2261@electric-eye.fr.zoreil.com> <9e246b4d0704271353g105ecd62j4f35a6e9027ad590@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tim Durack <tdurack@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46008 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757280AbXD0WKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 18:10:13 -0400
Content-Disposition: inline
In-Reply-To: <9e246b4d0704271353g105ecd62j4f35a6e9027ad590@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tim Durack <tdurack@gmail.com> :
[...]
> Link failover does not work reliably. Carrier-detect appears to be
> working, so I don't think that is an issue.
> 
> 
> A disturbing problem is mac corruption after "modprobe -r r8169; modprobe 
> r8169"
> 
> ip link sh:
> 
> 2: eth5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
>    link/ether 00:00:00:00:68:93 brd ff:ff:ff:ff:ff:ff
> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast qlen 1000
>    link/ether 00:30:18:ab:68:94 brd ff:ff:ff:ff:ff:ff
> 4: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
>    link/ether 00:30:18:ab:68:95 brd ff:ff:ff:ff:ff:ff
> 
> eth5 mac was 00:30:18:ab:68:93 before the modprobe.

Can you revert patch #0012 and see if it changes this part of the problem ?

A tcpdump trace 1) before promiscuous mode 2) after promiscuous mode 3)
after link failure (i.e. failover does not work) would be welcome.

> Not sure what's going on here, but I'm starting to think these
> interfaces aren't the best in the world...

The maintainer/driver/hardware combination is a bit quirky at times
but it does not work too bad. :o)

-- 
Ueimor

Anybody got a battery for my Ultra 10 ?
