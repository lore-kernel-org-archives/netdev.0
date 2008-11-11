From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix ip6_mr_init error path
Date: Mon, 10 Nov 2008 16:35:14 -0800 (PST)
Message-ID: <20081110.163514.193380252.davem@davemloft.net>
References: <20081107142025.563493104@nptl.frec.bull.fr>
	<20081107142027.249107446@nptl.frec.bull.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43915
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753022AbYKKAfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2008 19:35:14 -0500
In-Reply-To: <20081107142027.249107446@nptl.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Fri, 07 Nov 2008 15:20:26 +0100

> The order of cleanup operations in the error/exit section of ip6_mr_init()
> is completely inversed. It should be the other way around.
> Also a del_timer() is missing in the error path.
> 
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Applied, thanks a lot Benjamin.
