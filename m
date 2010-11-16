From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] vlan: remove ndo_select_queue() logic
Date: Tue, 16 Nov 2010 11:24:54 -0800 (PST)
Message-ID: <20101116.112454.179916339.davem@davemloft.net>
References: <1289497978.17691.1582.camel@edumazet-laptop>
	<AANLkTik-b5jYgN9e2cgYQvW1V3kuHem2x6wDpw4_=GJJ@mail.gmail.com>
	<1289504565.17691.1710.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, netdev@vger.kernel.org, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47964
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757478Ab0KPTYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 14:24:30 -0500
In-Reply-To: <1289504565.17691.1710.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 11 Nov 2010 20:42:45 +0100

> [PATCH] vlan: remove ndo_select_queue() logic
> 
> Now vlan are lockless, we dont need special ndo_select_queue() logic.
> dev_pick_tx() will do the multiqueue stuff on the real device transmit.
> 
> Suggested-by: Jesse Gross <jesse@nicira.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Also applied, but again there were conflicts I had to resolve,
please check that I got it right.

Thanks.
