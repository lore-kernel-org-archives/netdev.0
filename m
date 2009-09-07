From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] wan: dlci/sdla transmit return dehacking
Date: Mon, 07 Sep 2009 01:57:32 -0700 (PDT)
Message-ID: <20090907.015732.68655184.davem@davemloft.net>
References: <20090904143439.c44f61ee.sfr@canb.auug.org.au>
	<20090903.213548.46609322.davem@davemloft.net>
	<20090904083346.43885303@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36940
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752496AbZIGI5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 04:57:17 -0400
In-Reply-To: <20090904083346.43885303@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 4 Sep 2009 08:33:46 -0700

> This is a brute force removal of the wierd slave interface done for DLCI -> SDLA
> transmit. Before it was using non-standard return values and freeing skb in caller.
> This changes it to using normal return values, and freeing in the callee.
> Luckly only one driver pair was doing this. Not tested on real hardware,
> in fact I wonder if this driver pair is even being used by any users.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Irregardless of what we should do with the SDLA driver, this patch
should go in while that code is still in the tree.

Applied to net-next-2.6, thanks.
