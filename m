From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] [PPPOE] fix return value of
 __pppoe_xmit() method.
Date: Sat, 05 Jun 2010 02:54:03 -0700 (PDT)
Message-ID: <20100605.025403.212701871.davem@davemloft.net>
References: <AANLkTimW3olb9_3Wo8HvtYRP_LOCEeHDGWuVQvGMvFxd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46378
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932720Ab0FEJxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 05:53:53 -0400
In-Reply-To: <AANLkTimW3olb9_3Wo8HvtYRP_LOCEeHDGWuVQvGMvFxd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Thu, 3 Jun 2010 18:02:29 +0300

>  __pppoe_xmit() in drivers/net/pppoe always returns 1.
> When the methods fails (via goto abort), it should return 0 and not 1.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

APplied.
