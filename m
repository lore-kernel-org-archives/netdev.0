From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-2.6][NEIGH] Updating affected neighbours when about
 MAC address change
Date: Sun, 23 Dec 2007 21:11:26 +0900 (JST)
Message-ID: <20071223.211126.118866275.yoshfuji@linux-ipv6.org>
References: <31436f4a0712230341x5a0abf08q7e6f7917ba7e38f0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: dshwatrz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44295 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788AbXLWMKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2007 07:10:48 -0500
In-Reply-To: <31436f4a0712230341x5a0abf08q7e6f7917ba7e38f0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <31436f4a0712230341x5a0abf08q7e6f7917ba7e38f0@mail.gmail.com> (at Sun, 23 Dec 2007 13:41:36 +0200), "David Shwatrz" <dshwatrz@gmail.com> says:

> I had written a small patch to neigh_changeaddr() in net/core/neighbour.c
> against the 2.6 git net tree, which sends a gratuitous ARP to update
> the list of
> all the involved neighbours with the change of MAC address.
> The patch is for neigh_changeaddr() only.

Though I can see no patch, but I disagree. ;-)
I do think you should change arp_netdev_event() and ndisc_netdev_event().

--yoshfuji
