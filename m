From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] tulip: use integrated netdev stats
Date: Fri, 03 Sep 2010 09:45:12 -0700 (PDT)
Message-ID: <20100903.094512.42790017.davem@davemloft.net>
References: <1283521963.2453.848.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44243
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755961Ab0ICQoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 12:44:55 -0400
In-Reply-To: <1283521963.2453.848.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 03 Sep 2010 15:52:43 +0200

> struct tulip_private is a bit large (order-1 allocation even on 32bit
> arch), try to shrink it, remove its net_device_stats field.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
