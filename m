From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: trans_start cleanups
Date: Mon, 10 May 2010 05:02:32 -0700 (PDT)
Message-ID: <20100510.050232.141234126.davem@davemloft.net>
References: <1273435324.2325.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57427
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752521Ab0EJMCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 08:02:24 -0400
In-Reply-To: <1273435324.2325.61.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 09 May 2010 22:02:03 +0200

> Now that core network takes care of trans_start updates, dont do it
> in drivers themselves, if possible. Drivers can avoid one cache miss
> (on dev->trans_start) in their start_xmit() handler.
> 
> Exceptions are NETIF_F_LLTX drivers
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks good, applied, thanks Eric.
