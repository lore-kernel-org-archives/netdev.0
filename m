From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv4: speedup inet_dump_ifaddr()
Date: Fri, 13 Nov 2009 20:50:15 -0800 (PST)
Message-ID: <20091113.205015.125854704.davem@davemloft.net>
References: <4AFC1798.1060501@gmail.com>
	<20091112091221.3d523253@nehalam>
	<4AFC4979.7030007@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50271
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752795AbZKNEt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 23:49:59 -0500
In-Reply-To: <4AFC4979.7030007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 12 Nov 2009 18:44:25 +0100

> [PATCH net-next-2.6] ipv4: speedup inet_dump_ifaddr()
> 
> When handling large number of netdevices, inet_dump_ifaddr()
> is very slow because it has O(N2) complexity.
> 
> Instead of scanning one single list, we can use the NETDEV_HASHENTRIES
> sub lists of the dev_index hash table, and RCU lookups.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
