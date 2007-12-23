From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-2.6][NEIGH] Updating affected neighbours when about
 MAC address change
Date: Sun, 23 Dec 2007 22:04:47 +0900 (JST)
Message-ID: <20071223.220447.56355925.yoshfuji@linux-ipv6.org>
References: <31436f4a0712230424n1cfaeb27o463e62093af41090@mail.gmail.com>
	<20071223.213841.108421688.yoshfuji@linux-ipv6.org>
	<1198413975.4423.65.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: dshwatrz@gmail.com, davem@davemloft.net, netdev@vger.kernel.org,
	kaber@trash.net, yoshfuji@linux-ipv6.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44305 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbXLWNEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2007 08:04:09 -0500
In-Reply-To: <1198413975.4423.65.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <1198413975.4423.65.camel@localhost> (at Sun, 23 Dec 2007 07:46:15 -0500), jamal <hadi@cyberus.ca> says:

> On Sun, 2007-23-12 at 21:38 +0900, YOSHIFUJI Hideaki / 吉藤英明 wrote:
> > In article <31436f4a0712230424n1cfaeb27o463e62093af41090@mail.gmail.com> (at Sun, 23 Dec 2007 14:24:00 +0200), "David Shwatrz" <dshwatrz@gmail.com> says:
> > 
> > > Regarding your answer;  I accept it and I will soon send a revised
> > > version of this patch (making changes to
> > >  arp_netdev_event() and ndisc_netdev_event().)
> > > I had  IPv4 in mind, there is no reason that it will no be also in IPv6.
> > 
> > You should iterate all of ifa_list (for IPv4) / addr_list (for IPv6).
> > For IPv6, we also have anycast (maintained by ac_list) as well.
> > 
> 
> Hrm, how is this going to work for the case of multiple MACs on a
> device? 
> Changing one MAC address doesnt equate to issuing a grat arp with _the
> new MAC_ for all ifa (given each MAC may be map to a different ifa) 

If the secondary MACs are used with ARP/NDP, we should take care of
that, but I think we use the primary MAC for ARP/NDP, no?
(In other words, we always use primary MAC for ARP reply / NA, no?)

--yoshfuji
