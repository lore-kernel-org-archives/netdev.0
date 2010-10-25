From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] tunnels: add _rcu annotations
Date: Mon, 25 Oct 2010 13:10:54 -0700 (PDT)
Message-ID: <20101025.131054.232757418.davem@davemloft.net>
References: <1287991996.2658.5385.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49979
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757680Ab0JYUKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 16:10:31 -0400
In-Reply-To: <1287991996.2658.5385.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 Oct 2010 09:33:16 +0200

> (struct ip6_tnl)->next is rcu protected :
> (struct ip_tunnel)->next is rcu protected :
> (struct xfrm6_tunnel)->next is rcu protected :
> 
> add __rcu annotation and proper rcu primitives.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
