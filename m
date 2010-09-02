From: David Miller <davem@davemloft.net>
Subject: Re: [PATCN net-next-2.6] net: dev_add_pack() & __dev_remove_pack()
 changes
Date: Thu, 02 Sep 2010 10:12:30 -0700 (PDT)
Message-ID: <20100902.101230.260098512.davem@davemloft.net>
References: <1283435626.2454.764.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43497
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751370Ab0IBRMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 13:12:13 -0400
In-Reply-To: <1283435626.2454.764.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Sep 2010 15:53:46 +0200

> Add a small helper ptype_head() to get the head to manipulate
> 
> dev_add_pack() & __dev_remove_pack() can use a spinlock without
> blocking BH, since softirq use RCU, and these functions are run from
> process context only.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks good, applied, thanks Eric.
