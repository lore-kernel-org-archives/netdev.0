From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix ip_mr_init() error path
Date: Wed, 19 Nov 2008 14:07:50 -0800 (PST)
Message-ID: <20081119.140750.227127180.davem@davemloft.net>
References: <20081117084154.369686935@nptl.frec.bull.fr>
	<20081117084157.953413470@nptl.frec.bull.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34951
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750738AbYKSWHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 17:07:50 -0500
In-Reply-To: <20081117084157.953413470@nptl.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Mon, 17 Nov 2008 09:41:55 +0100

> Similarly to IPv6 ip6_mr_init() (fixed last week), the order of cleanup
> operations in the error/exit section of ip_mr_init() is completely 
> inversed. It should be the other way around.
> Also a del_timer() is missing in the error path.
> 
> I should have guessed last week that this same error existed in ipmr.c
> too, as ip6mr.c is largely inspired by ipmr.c.
> 
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Applied.

