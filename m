From: Naoto MATSUMOTO <n-matsumoto@sakura.ad.jp>
Subject: Re: ethtool 3.5 released
Date: Mon, 06 Aug 2012 10:27:24 +0900
Message-ID: <20120806102723.D637.C42C3789@sakura.ad.jp>
References: <1344023317.2610.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sakura.ad.jp ([210.224.172.11]:31258 "EHLO
	mail.sakura.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755133Ab2HFBd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Aug 2012 21:33:27 -0400
In-Reply-To: <1344023317.2610.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Dear Ben.

FYI(For Your Information)
This is Naoto MATSUMOTO, Senior Researcher, SAKURA Internet.

We tried ethtool 3.5 on 40GbE NIC(Mellanox), it's result here.
-----------------------------------------------------------------------
# ./ethtool --version
ethtool version 3.5

# ./ethtool eth1
Settings for eth1:
        Supported ports: [ TP ]
        Supported link modes:   10000baseT/Full
        Supported pause frame use: No
        Supports auto-negotiation: No
        Advertised link modes:  10000baseT/Full
        Advertised pause frame use: No
        Advertised auto-negotiation: No
        Speed: 40000Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: off
        MDI-X: Unknown
        Supports Wake-on: d
        Wake-on: d
        Current message level: 0x00000014 (20)
                               link ifdown
        Link detected: yes


Our 40GbE NIC Firmware/Dirver status are here.
-----------------------------------------------------------------------
Mellanox ConnectX HCA Ethernet driver v1.5.8.3 (June 2012)
Ethernet controller: Mellanox Technologies MT27500 Family [ConnectX-3]
Firmware Version: 2.10.800
-----------------------------------------------------------------------


And We were testing 10GbE(Intel) NIC and your 40GbE NIC in our lab
using ethtool with added some debug code.

-----------------------------------------------------------------------
# ./ethtool-p eth5 (10GbE NIC by Intel)
Settings for eth5:
        Supported ports: [ FIBRE ]
        Supported link modes:   10000baseT/Full

        mask == 5120 <--- ep->support number

# ./ethtool-p eth1 (40GbE NIC by Mellanox)
Settings for eth1:
        Supported ports: [ TP ]
        Supported link modes:   10000baseT/Full

        mask == 4224 <--- ep->support number
-----------------------------------------------------------------------

It's firmware problem I thinks. But Just Information for you ;-)

regards,
--
Naoto MATSUMOTO

On Fri, 3 Aug 2012 20:48:37 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> ethtool version 3.5 has been released.
> 
> Home page: https://ftp.kernel.org/pub/software/network/ethtool/
> Download link:
> https://ftp.kernel.org/pub/software/network/ethtool/ethtool-3.1.tar.gz
> 
> Release notes:
> 
> 	* Feature: Display support for 40G link modes


-- 
SAKURA Internet Inc. / Senior Researcher
Naoto MATSUMOTO <n-matsumoto@sakura.ad.jp>
SAKURA Research Center <http://research.sakura.ad.jp/>
