From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next-2.6] sch_sfq: allow big packets and be fair
Date: Fri, 31 Dec 2010 12:48:17 -0800 (PST)
Message-ID: <20101231.124817.242139130.davem@davemloft.net>
References: <1292936699.2720.23.camel@edumazet-laptop>
	<20101228.134655.112609314.davem@davemloft.net>
	<1293609213.2691.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, kaber@trash.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44968
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751904Ab0LaUrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 15:47:47 -0500
In-Reply-To: <1293609213.2691.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 29 Dec 2010 08:53:33 +0100

> [PATCH v3 net-next-2.6] sch_sfq: allow big packets and be fair
> 
> SFQ is currently 'limited' to small packets, because it uses a 15bit
> allotment number per flow. Introduce a scale by 8, so that we can handle
> full size TSO/GRO packets.
> 
> Use appropriate handling to make sure allot is positive before a new
> packet is dequeued, so that fairness is respected.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: Jarek Poplawski <jarkao2@gmail.com>
> Cc: Patrick McHardy <kaber@trash.net>

Applied, thanks Eric.
