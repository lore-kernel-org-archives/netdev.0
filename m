From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: Fix lockdep warning after
 bond_vlan_rx_register()
Date: Wed, 27 Oct 2010 14:21:32 -0700 (PDT)
Message-ID: <20101027.142132.71103913.davem@davemloft.net>
References: <20101027120334.GA11247@ff.dom.local>
	<1288184416.2709.109.camel@edumazet-laptop>
	<20101027170822.GA1902@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, jesse@nicira.com,
	fubar@us.ibm.com
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41978
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932291Ab0J0VVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 17:21:08 -0400
In-Reply-To: <20101027170822.GA1902@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 27 Oct 2010 19:08:22 +0200

> [ Full info at netdev: Wed, 27 Oct 2010 12:24:30 +0200
>   Subject: [BUG net-2.6 vlan/bonding] lockdep splats ]
> 
> Use BH variant of write_lock(&bond->lock) (as elsewhere in bond_main)
> to prevent this dependency.
> 
> Fixes commit f35188faa0fbabefac476536994f4b6f3677380f [v2.6.36]
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Tested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jay Vosburgh <fubar@us.ibm.com>

Applied.
