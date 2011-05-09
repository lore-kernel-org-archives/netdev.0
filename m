From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] garp: remove one synchronize_rcu() call
Date: Mon, 09 May 2011 11:42:08 -0700 (PDT)
Message-ID: <20110509.114208.71122143.davem@davemloft.net>
References: <1304948155.3342.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, kaber@trash.net, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54136
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753445Ab1EISmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 14:42:40 -0400
In-Reply-To: <1304948155.3342.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 09 May 2011 15:35:55 +0200

> Speedup vlan dismantling in CONFIG_VLAN_8021Q_GVRP=y cases,
> by using a call_rcu() to free the memory instead of waiting with
> expensive synchronize_rcu() [ while RTNL is held ]
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
