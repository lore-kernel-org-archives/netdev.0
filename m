From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv6: speedup inet6_dump_addr()
Date: Fri, 13 Nov 2009 20:50:34 -0800 (PST)
Message-ID: <20091113.205034.102618060.davem@davemloft.net>
References: <4AFC17A6.4040801@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50275
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753753AbZKNEuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 23:50:18 -0500
In-Reply-To: <4AFC17A6.4040801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 12 Nov 2009 15:11:50 +0100

> When handling large number of netdevices, inet6_dump_addr()
> is very slow because it has O(N^2) complexity.
> 
> Instead of scanning one single list, we can use the NETDEV_HASHENTRIES
> sub lists of the dev_index hash table, and RCU lookups.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
