From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-2.6.26] [IPV6] Return NET_RX_DROP when a packet is
 dropped in ipv6_rcv().
Date: Mon, 14 Apr 2008 22:52:09 +0900 (JST)
Message-ID: <20080414.225209.92939349.yoshfuji@linux-ipv6.org>
References: <eb3ff54b0804140615u3dd4549fie83ae6818c33beba@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33518 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212AbYDNNuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 09:50:25 -0400
In-Reply-To: <eb3ff54b0804140615u3dd4549fie83ae6818c33beba@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <eb3ff54b0804140615u3dd4549fie83ae6818c33beba@mail.gmail.com> (at Mon, 14 Apr 2008 16:15:54 +0300), "Rami Rosen" <ramirose@gmail.com> says:

> Hi,
> - The IPv6 handler for receiving packets is ipv6_rcv() in net/ipv6/ip6_input.c.
> It is called by netif_receive_skb() (net/core/dev.c)
> According to the documentation, the return value of netif_receive_skb() should
> be NET_RX_DROP when the packet is dropped; though this return value
> is usually not used (except maybe for congestion), this patch fixes the
> ipv6_rcv() to return NET_RX_DROP when the packet is dropped (note that
> NET_RX_DROP value **is not** 0 but 1; NET_RX_SUCCESS value is in fact	0).

Well yes, and I think we should fix other paths as well, right?
So, I'm going to defer this for now.

--yoshfuji
