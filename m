From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [AX25] missplaced sock_put(sk)
Date: Thu, 26 Aug 2010 15:16:57 -0700 (PDT)
Message-ID: <20100826.151657.116364894.davem@davemloft.net>
References: <4C76DF30.7080908@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, bpidoux@free.fr
To: f6bvp@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47891
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753836Ab0HZWQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 18:16:41 -0400
In-Reply-To: <4C76DF30.7080908@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bernard F6BVP <f6bvp@free.fr>
Date: Thu, 26 Aug 2010 23:40:00 +0200

> [PATCH] [AX25] missplaced sock_put(sk)
> 
> This patch moves a missplaced sock_put(sk) after
> bh_unlock_sock(sk)
> like in other parts of AX25 driver.
> 
> Signed-off-by: Bernard Pidoux <f6bvp@free.fr>

Applied, thank you.
