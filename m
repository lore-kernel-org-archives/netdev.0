From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/17] drivers/isdn/hardware/mISDN: Add missing
 spin_unlock
Date: Sat, 29 May 2010 00:19:50 -0700 (PDT)
Message-ID: <20100529.001950.71558279.davem@davemloft.net>
References: <Pine.LNX.4.64.1005261754560.23743@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38357
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754032Ab0E2HTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 May 2010 03:19:39 -0400
In-Reply-To: <Pine.LNX.4.64.1005261754560.23743@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Wed, 26 May 2010 17:55:10 +0200 (CEST)

> From: Julia Lawall <julia@diku.dk>
> 
> Add a spin_unlock missing on the error path.  The return value of write_reg
> seems to be completely ignored, so it seems that the lock should be
> released in every case.
> 
> The semantic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied, thanks.
