From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] de2104x: wrong MAC address fix
Date: Mon, 13 Oct 2008 18:49:57 -0700 (PDT)
Message-ID: <20081013.184957.229112523.davem@davemloft.net>
References: <20081013180459.GA3389@tuba>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: martin-langer@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56544
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754031AbYJNBuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 21:50:21 -0400
In-Reply-To: <20081013180459.GA3389@tuba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Langer <martin-langer@gmx.de>
Date: Mon, 13 Oct 2008 20:04:59 +0200

> The de2104x returns sometimes a wrong MAC address. The wrong one is
> like the original one, but it comes with an one byte shift. I found
> this bug on an older alpha ev5 cpu. More details are available in Gentoo
> bugreport #240718.
> 
> It seems the hardware is sometimes a little bit too slow for an
> immediate access. This patch solves the problem by introducing a small
> udelay.
> 
> Signed-off-by: Martin Langer <martin-langer@gmx.de>

Looks good, applied, thanks Martin.

> --- drivers/net/tulip/de2104x.c_ORIGINAL	2008-10-10 00:13:53.000000000 +0200
> +++ drivers/net/tulip/de2104x.c	2008-10-11 19:04:32.000000000 +0200
> @@ -1689,6 +1689,7 @@

Please -p1 base your patches in the future.
