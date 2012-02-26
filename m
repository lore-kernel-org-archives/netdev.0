From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4_en: dont change mac_header on xmit
Date: Sun, 26 Feb 2012 14:27:23 -0500 (EST)
Message-ID: <20120226.142723.2089903339861181922.davem@davemloft.net>
References: <953B660C027164448AE903364AC447D2618B88E7@MTLDAG02.mtl.com>
	<74A0102445410646AFACC089FD94803A616DC2FE@MTLDAG02.mtl.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	yevgenyp@mellanox.com
To: eugenia@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752368Ab2BZT1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2012 14:27:30 -0500
In-Reply-To: <74A0102445410646AFACC089FD94803A616DC2FE@MTLDAG02.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>
Date: Sun, 26 Feb 2012 19:12:12 +0000

> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> Sent: Saturday, February 25, 2012 12:51 PM
> 
>> A driver xmit function is not allowed to change skb without special
>> care.
>>
>> mlx4_en_xmit() should not call skb_reset_mac_header() and instead should
>> use skb->data to access ethernet header.
>>
>> This removes a dumb test : if (ethh && ethh->h_dest)
>>
>> Also remove this slow mlx4_en_mac_to_u64() call, we can use
>> get_unaligned() to get faster code.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
>> ---
>> Please test this patch before we can commit it, thanks !
> 
> Tested and approved, thanks.
> --

Applied.
