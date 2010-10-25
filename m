From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_ns: add __rcu annotations
Date: Mon, 25 Oct 2010 14:19:33 -0700 (PDT)
Message-ID: <20101025.141933.242147615.davem@davemloft.net>
References: <1288012811.2826.119.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48803
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756097Ab0JYVTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 17:19:10 -0400
In-Reply-To: <1288012811.2826.119.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 Oct 2010 15:20:11 +0200

> add __rcu annotation to (struct net)->gen, and use
> rcu_dereference_protected() in net_assign_generic()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
