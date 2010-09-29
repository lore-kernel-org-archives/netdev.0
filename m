From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ip6tnl: percpu stats accounting
Date: Wed, 29 Sep 2010 13:27:33 -0700 (PDT)
Message-ID: <20100929.132733.229731825.davem@davemloft.net>
References: <1285680214.3154.65.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34976
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755805Ab0I2U1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 16:27:12 -0400
In-Reply-To: <1285680214.3154.65.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 28 Sep 2010 15:23:34 +0200

> Maintain per_cpu tx_bytes, tx_packets, rx_bytes, rx_packets.
> 
> Other seldom used fields are kept in netdev->stats structure, possibly
> unsafe.
> 
> This is a preliminary work to support lockless transmit path, and
> correct RX stats, that are already unsafe.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
