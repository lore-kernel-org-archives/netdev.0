From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: fix a race in irlan_eth_xmit()
Date: Sun, 22 Aug 2010 00:09:23 -0700 (PDT)
Message-ID: <20100822.000923.112613186.davem@davemloft.net>
References: <1282127083.2194.45.camel@edumazet-laptop>
	<20100819.004202.84378290.davem@davemloft.net>
	<1282297893.2484.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37918
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751324Ab0HVHJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 03:09:07 -0400
In-Reply-To: <1282297893.2484.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Aug 2010 11:51:33 +0200

> [PATCH net-next-2.6] irda: use net_device_stats from struct net_device
> 
> struct net_device has its own struct net_device_stats member, so use
> this one instead of a private copy in the irlan_cb struct.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
