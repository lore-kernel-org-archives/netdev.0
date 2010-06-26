From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] arp: RCU change in arp_solicit()
Date: Fri, 25 Jun 2010 21:33:59 -0700 (PDT)
Message-ID: <20100625.213359.173865711.davem@davemloft.net>
References: <1277228595.3057.730.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51844
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751139Ab0FZEdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jun 2010 00:33:46 -0400
In-Reply-To: <1277228595.3057.730.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Jun 2010 19:43:15 +0200

> Avoid two atomic ops in arp_solicit()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

RCU is like a NAND gate, with it you can build any locking scheme :-)

Applied, thanks Eric.
