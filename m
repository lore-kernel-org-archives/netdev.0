From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: loopback driver cleanup
Date: Sun, 26 Sep 2010 19:05:41 -0700 (PDT)
Message-ID: <20100926.190541.02266256.davem@davemloft.net>
References: <1285321911.2503.48.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57243
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758758Ab0I0CFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 22:05:20 -0400
In-Reply-To: <1285321911.2503.48.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 24 Sep 2010 11:51:51 +0200

> loopback driver uses dev->ml_priv to store its percpu stats pointer.
> It uses ugly casts "(void __percpu __force *)" to shut up sparse
> complains.
> 
> Define an union to better document we use ml_priv in loopback driver and
> define a lstats field with appropriate types.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
