From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] raw: avoid two atomics in xmit
Date: Mon, 07 Jun 2010 01:09:37 -0700 (PDT)
Message-ID: <20100607.010937.173865706.davem@davemloft.net>
References: <1275639837.2482.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54535
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752724Ab0FGIJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 04:09:27 -0400
In-Reply-To: <1275639837.2482.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 04 Jun 2010 10:23:57 +0200

> Avoid two atomic ops per raw_send_hdrinc() call
> 
> Avoid two atomic ops per raw6_send_hdrinc() call
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

I'm starting to feel like we now use the implicit skb dst ref stuff
more than the usual cloning, which is great! :-)
