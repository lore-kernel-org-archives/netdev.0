From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: introduce alloc_skb_order0
Date: Sat, 16 Oct 2010 11:53:42 -0700 (PDT)
Message-ID: <20101016.115342.71098036.davem@davemloft.net>
References: <20101011155556.GA2431@redhat.com>
	<1286813133.2737.36.camel@edumazet-laptop>
	<1286831867.30423.80.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54698
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753547Ab0JPSxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Oct 2010 14:53:19 -0400
In-Reply-To: <1286831867.30423.80.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 11 Oct 2010 23:17:47 +0200

> [PATCH net-next] r8169: use 50% less ram for RX ring
> 
> Using standard skb allocations in r8169 leads to order-3 allocations (if
> PAGE_SIZE=4096), because NIC needs 16383 bytes, and skb overhead makes
> this bigger than 16384 -> 32768 bytes per "skb"
> 
> Using kmalloc() permits to reduce memory requirements of one r8169 nic
> by 4Mbytes. (256 frames * 16Kbytes). This is fine since a hardware bug
> requires us to copy incoming frames, so we build real skb when doing
> this copy.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
