From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] vlan: remove ndo_select_queue() logic
Date: Fri, 12 Nov 2010 16:50:13 +0100
Message-ID: <4CDD6235.20004@trash.net>
References: <1289468520.17691.1018.camel@edumazet-laptop>	 <AANLkTikBkUNfrfSZkoVd1xzisD3jgg5kVUUZC45gNpde@mail.gmail.com>	 <1289497978.17691.1582.camel@edumazet-laptop>	 <AANLkTik-b5jYgN9e2cgYQvW1V3kuHem2x6wDpw4_=GJJ@mail.gmail.com> <1289504565.17691.1710.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jesse Gross <jesse@nicira.com>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35197 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753150Ab0KLPuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 10:50:15 -0500
In-Reply-To: <1289504565.17691.1710.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 11.11.2010 20:42, schrieb Eric Dumazet:
> [PATCH] vlan: remove ndo_select_queue() logic
> 
> Now vlan are lockless, we dont need special ndo_select_queue() logic.
> dev_pick_tx() will do the multiqueue stuff on the real device transmit.
> 
> Suggested-by: Jesse Gross <jesse@nicira.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Both patches look good to me.

Acked-by: Patrick McHardy <kaber@trash.net>
