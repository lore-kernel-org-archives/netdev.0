From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv4: RCU conversion of
 ip_route_input_slow/ip_route_input_mc
Date: Thu, 03 Jun 2010 03:20:45 -0700 (PDT)
Message-ID: <20100603.032045.38081781.davem@davemloft.net>
References: <1275542491.29413.71.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55471
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933755Ab0FCKUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:20:35 -0400
In-Reply-To: <1275542491.29413.71.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Jun 2010 07:21:31 +0200

> [PATCH] ipv4: rcu conversion of ip_route_input_slow/ip_route_input_mc
> 
> Avoid two atomic ops on struct in_device refcount per incoming packet,
> if slow path taken, (or route cache disabled)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
