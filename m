From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] macvlan: Use compare_ether_addr_64bits()
Date: Tue, 01 Sep 2009 17:43:48 -0700 (PDT)
Message-ID: <20090901.174348.242377529.davem@davemloft.net>
References: <4A9D41BD.9000406@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40454
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755418AbZIBAnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 20:43:33 -0400
In-Reply-To: <4A9D41BD.9000406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 01 Sep 2009 17:46:05 +0200

> To speedup ether addresses compares, we can use compare_ether_addr_64bits()
> (all operands are guaranteed to be at least 8 bytes long)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
