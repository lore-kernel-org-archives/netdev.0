From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] inet: RCU changes in inetdev_by_index()
Date: Tue, 19 Oct 2010 03:51:26 -0700 (PDT)
Message-ID: <20101019.035126.39177604.davem@davemloft.net>
References: <1287484766.2676.74.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33744
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758160Ab0JSKvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 06:51:03 -0400
In-Reply-To: <1287484766.2676.74.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 19 Oct 2010 12:39:26 +0200

> Convert inetdev_by_index() to not increment in_dev refcount.
> 
> Callers hold RCU or RTNL, and should not decrement in_dev refcount.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
