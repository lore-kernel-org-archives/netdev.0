From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pppoe: fix race at init time
Date: Wed, 12 Aug 2009 16:40:07 -0700 (PDT)
Message-ID: <20090812.164007.240124819.davem@davemloft.net>
References: <20090728184834.GD4678@lenovo>
	<43d009740907282055t44bfa2e2md3afa514d4b2d7e6@mail.gmail.com>
	<20090729144642.GA5094@lenovo>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: for.poige+bugzilla.kernel.org@gmail.com, eric.dumazet@gmail.com,
	xemul@openvz.org, akpm@linux-foundation.org, netdev@vger.kernel.org
To: gorcunov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41384
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750934AbZHLXj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 19:39:57 -0400
In-Reply-To: <20090729144642.GA5094@lenovo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Wed, 29 Jul 2009 18:46:42 +0400

> net,pppoe: fixup module init/exit subsequent calls
> 
> pernet data should allocated first and freed last
> on module init/exit routines otherwise it's possible
> to have unserialized calls to packet handling routines.
> 
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>

Still no feedback on this one, but it looks totally correct to me.

So I've applied it to net-next-2.6 so that it doesn't get lost and if
it turns out we need it to actually fix a user reported bug we can
toss it into net-2.6 too.
