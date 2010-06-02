From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: force a dst reference in __xfrm_route_forward()
Date: Wed, 02 Jun 2010 02:27:01 -0700 (PDT)
Message-ID: <20100602.022701.35807703.davem@davemloft.net>
References: <1275422689.2638.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33174
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751329Ab0FBJ0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 05:26:52 -0400
In-Reply-To: <1275422689.2638.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 01 Jun 2010 22:04:49 +0200

> Packets going through __xfrm_route_forward() have a not refcounted dst
> entry, since we enabled a noref forwarding path.
> 
> xfrm_lookup() might incorrectly release this dst entry.
> 
> It's a bit late to make invasive changes in xfrm_lookup(), so lets force
> a refcount in this path.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks for fixing this bug Eric.
