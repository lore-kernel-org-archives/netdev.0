From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: sk_drops consolidation part 2
Date: Sun, 18 Oct 2009 18:54:45 -0700 (PDT)
Message-ID: <20091018.185445.43365815.davem@davemloft.net>
References: <4AD68D4C.2080108@gmail.com>
	<20091014.204021.97690983.davem@davemloft.net>
	<4AD6F598.4080007@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47243
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750918AbZJSByW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 21:54:22 -0400
In-Reply-To: <4AD6F598.4080007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 15 Oct 2009 12:12:40 +0200

> - skb_kill_datagram() can increment sk->sk_drops itself, not callers.
> 
> - UDP on IPV4 & IPV6 dropped frames (because of bad checksum or policy checks) increment sk_drops
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
