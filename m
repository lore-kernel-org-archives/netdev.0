From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ethtool: reduce stack usage
Date: Mon, 15 Feb 2010 21:55:23 -0800 (PST)
Message-ID: <20100215.215523.200992193.davem@davemloft.net>
References: <1266243840.8262.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41399
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751247Ab0BPFzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 00:55:08 -0500
In-Reply-To: <1266243840.8262.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 15 Feb 2010 15:24:00 +0100

> dev_ethtool() is currently using 604 bytes of stack, even with gcc-4.4.2
> 
> objdump -d vmlinux | scripts/checkstack.pl
> ...
> 0xc04bbc33 dev_ethtool [vmlinux]:			604
> ...
> Adding noinline attributes to selected functions can reduce stack usage.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
