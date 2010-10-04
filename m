From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] ipmr: RCU conversion of mroute_sk
Date: Sun, 03 Oct 2010 21:51:40 -0700 (PDT)
Message-ID: <20101003.215140.71120725.davem@davemloft.net>
References: <1285985701.2582.522.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39882
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751716Ab0JDEvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 00:51:19 -0400
In-Reply-To: <1285985701.2582.522.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 02 Oct 2010 04:15:01 +0200

> Use RCU and RTNL to protect (struct mr_table)->mroute_sk
> 
> Readers use RCU, writers use RTNL.
> 
> ip_ra_control() already use an RCU grace period before
> ip_ra_destroy_rcu(), so we dont need synchronize_rcu() in 
> mrtsock_destruct()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
