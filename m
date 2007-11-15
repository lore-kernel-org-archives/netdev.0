From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Thu, 15 Nov 2007 04:05:30 -0800 (PST)
Message-ID: <20071115.040530.205831740.davem@davemloft.net>
References: <473BF7FD.7010403@hartkopp.net>
	<1195113860.27113.34.camel@localhost>
	<ygfmytfbubd.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, oliver@hartkopp.net,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	kaber@trash.net, oliver.hartkopp@volkswagen.de
To: urs.thuermann@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48258
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757613AbXKOMFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 07:05:31 -0500
In-Reply-To: <ygfmytfbubd.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Urs Thuermann <urs.thuermann@gmx.de>
Date: 15 Nov 2007 12:51:34 +0100

> I prefer our code because it is shorter (fits into one line) and can
> be used anywhere where an expression is allowed compared to only where
> a statement is allowed.  Actually, I first had
> 
>         #define DBG( ... )   ((debug & 1) && printk( ... ))
> 
> and so on, but that didn't work with can_debug_{cframe,sbk} since they
> return void.
> 
> Admitted, the benefit of expr vs. statement is really negligible and
> since this issue has come up several times I will change these macros
> using do-while.

I really frown upon these local debugging macros people tend to want
to submit with their changes.

It really craps up the tree, even though it might be useful to you.

So please remove this stuff or replace the debugging statements
with some generic kernel debugging facility, there are several.

Thank you.
