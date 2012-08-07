From: Naoto MATSUMOTO <n-matsumoto@sakura.ad.jp>
Subject: Re[2]: ethtool 3.5 released
Date: Tue, 07 Aug 2012 10:36:20 +0900
Message-ID: <20120807103619.5C99.C42C3789@sakura.ad.jp>
References: <20120806102723.D637.C42C3789@sakura.ad.jp> <1344271283.2632.6.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sakura.ad.jp ([210.224.172.11]:21120 "EHLO
	mail.sakura.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756926Ab2HGBgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 21:36:23 -0400
In-Reply-To: <1344271283.2632.6.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi, Ben. Thanks your reply for me.

On Mon, 6 Aug 2012 17:41:23 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> >         Port: Twisted Pair
> 
> 40G twisted-pair, eh?

We are using this one(cable). 
http://www.mellanox.com/content/pages.php?pg=cables

> >         PHYAD: 0
> >         Transceiver: internal
> >         Auto-negotiation: off
> >         MDI-X: Unknown
> >         Supports Wake-on: d
> >         Wake-on: d
> >         Current message level: 0x00000014 (20)
> >                                link ifdown
> >         Link detected: yes
> > 
> > 
> > Our 40GbE NIC Firmware/Dirver status are here.
> > -----------------------------------------------------------------------
> > Mellanox ConnectX HCA Ethernet driver v1.5.8.3 (June 2012)
> > Ethernet controller: Mellanox Technologies MT27500 Family [ConnectX-3]
> > Firmware Version: 2.10.800
> > -----------------------------------------------------------------------
> > 
> > 
> > And We were testing 10GbE(Intel) NIC and your 40GbE NIC in our lab
> > using ethtool with added some debug code.
> 
> I work for Solarflare, not Mellanox... and the patch adding 40G link
> modes came from Parav Pandit at Emulex.
> 
> [...]
> > It's firmware problem I thinks. But Just Information for you ;-)
> 
> Also, the 40G link mode flags were only just defined, so the driver
> probably has yet to be updated.
> 
> Ben.

I agree with you. and we'll wait for the MLX_GUY works ;-)

-- 
SAKURA Internet Inc. / Senior Researcher
Naoto MATSUMOTO <n-matsumoto@sakura.ad.jp>
SAKURA Research Center <http://research.sakura.ad.jp/>
