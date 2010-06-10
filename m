From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] icmp: RCU conversion in
 icmp_address_reply()
Date: Wed, 09 Jun 2010 18:07:45 -0700 (PDT)
Message-ID: <20100609.180745.260097424.davem@davemloft.net>
References: <1275986075.2475.73.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56529
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756033Ab0FJBHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 21:07:34 -0400
In-Reply-To: <1275986075.2475.73.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 08 Jun 2010 10:34:35 +0200

> - rcu_read_lock() already held by caller
> - use __in_dev_get_rcu() instead of in_dev_get() / in_dev_put()
> - remove goto out;
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
