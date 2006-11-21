From: David Miller <davem@davemloft.net>
Subject: Re: [-mm patch] make net/core/skbuff.c:skb_over_panic() static
Date: Mon, 20 Nov 2006 17:40:48 -0800 (PST)
Message-ID: <20061120.174048.105428563.davem@davemloft.net>
References: <20061117170205.GE31879@stusta.de>
	<20061120.195556.23029046.davem@davemloft.net>
	<20061120173716.10357a90.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35241
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030645AbWKUBko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 20:40:44 -0500
To: akpm@osdl.org
In-Reply-To: <20061120173716.10357a90.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Mon, 20 Nov 2006 17:37:16 -0800

> Adrian's patch is only applicable if my net-uninline-skb_put.patch is also
> applied.

I just realized that, see the email I just sent out.

> I'm not sure what to do with net-uninline-skb_put.patch.  It's a
> good patch if all that deudgging stuff is present in skb_put(), but
> it's a bad patch if it isn't present.  But it _is_ present.

Keep it in your tree if you want, it's never going into mine :)
