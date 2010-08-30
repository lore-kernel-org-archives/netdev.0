From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv6: struct xfrm6_tunnel in read_mostly
 section
Date: Mon, 30 Aug 2010 13:52:26 -0700 (PDT)
Message-ID: <20100830.135226.52179125.davem@davemloft.net>
References: <1283200030.2405.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56039
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754150Ab0H3UwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 16:52:10 -0400
In-Reply-To: <1283200030.2405.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 30 Aug 2010 22:27:10 +0200

> tunnel6_handlers chain being scanned for each incoming packet,
> make sure it doesnt share an often dirtied cache line.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Also applied, thanks Eric.
