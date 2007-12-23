From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-2.6][NEIGH] Updating affected neighbours when about
 MAC address change
Date: Sun, 23 Dec 2007 21:38:41 +0900 (JST)
Message-ID: <20071223.213841.108421688.yoshfuji@linux-ipv6.org>
References: <31436f4a0712230341x5a0abf08q7e6f7917ba7e38f0@mail.gmail.com>
	<20071223.211126.118866275.yoshfuji@linux-ipv6.org>
	<31436f4a0712230424n1cfaeb27o463e62093af41090@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: dshwatrz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44300 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbXLWMiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2007 07:38:02 -0500
In-Reply-To: <31436f4a0712230424n1cfaeb27o463e62093af41090@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <31436f4a0712230424n1cfaeb27o463e62093af41090@mail.gmail.com> (at Sun, 23 Dec 2007 14:24:00 +0200), "David Shwatrz" <dshwatrz@gmail.com> says:

> Regarding your answer;  I accept it and I will soon send a revised
> version of this patch (making changes to
>  arp_netdev_event() and ndisc_netdev_event().)
> I had  IPv4 in mind, there is no reason that it will no be also in IPv6.

You should iterate all of ifa_list (for IPv4) / addr_list (for IPv6).
For IPv6, we also have anycast (maintained by ac_list) as well.

--yoshfuji

