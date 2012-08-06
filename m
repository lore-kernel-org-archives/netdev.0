From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: ethtool 3.5 released
Date: Mon, 6 Aug 2012 17:41:23 +0100
Message-ID: <1344271283.2632.6.camel@bwh-desktop.uk.solarflarecom.com>
References: <1344023317.2610.13.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120806102723.D637.C42C3789@sakura.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Naoto MATSUMOTO <n-matsumoto@sakura.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:25905 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756684Ab2HFQl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 12:41:27 -0400
In-Reply-To: <20120806102723.D637.C42C3789@sakura.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-06 at 10:27 +0900, Naoto MATSUMOTO wrote:
> Dear Ben.
> 
> FYI(For Your Information)
> This is Naoto MATSUMOTO, Senior Researcher, SAKURA Internet.
> 
> We tried ethtool 3.5 on 40GbE NIC(Mellanox), it's result here.
> -----------------------------------------------------------------------
> # ./ethtool --version
> ethtool version 3.5
> 
> # ./ethtool eth1
> Settings for eth1:
>         Supported ports: [ TP ]
>         Supported link modes:   10000baseT/Full
>         Supported pause frame use: No
>         Supports auto-negotiation: No
>         Advertised link modes:  10000baseT/Full
>         Advertised pause frame use: No
>         Advertised auto-negotiation: No
>         Speed: 40000Mb/s
>         Duplex: Full
>         Port: Twisted Pair

40G twisted-pair, eh?

>         PHYAD: 0
>         Transceiver: internal
>         Auto-negotiation: off
>         MDI-X: Unknown
>         Supports Wake-on: d
>         Wake-on: d
>         Current message level: 0x00000014 (20)
>                                link ifdown
>         Link detected: yes
> 
> 
> Our 40GbE NIC Firmware/Dirver status are here.
> -----------------------------------------------------------------------
> Mellanox ConnectX HCA Ethernet driver v1.5.8.3 (June 2012)
> Ethernet controller: Mellanox Technologies MT27500 Family [ConnectX-3]
> Firmware Version: 2.10.800
> -----------------------------------------------------------------------
> 
> 
> And We were testing 10GbE(Intel) NIC and your 40GbE NIC in our lab
> using ethtool with added some debug code.

I work for Solarflare, not Mellanox... and the patch adding 40G link
modes came from Parav Pandit at Emulex.

[...]
> It's firmware problem I thinks. But Just Information for you ;-)

Also, the 40G link mode flags were only just defined, so the driver
probably has yet to be updated.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
