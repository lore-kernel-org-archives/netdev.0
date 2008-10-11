From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smc911x: Fix external PHY detection
Date: Sat, 11 Oct 2008 15:07:56 -0700 (PDT)
Message-ID: <20081011.150756.188234364.davem@davemloft.net>
References: <Pine.LNX.4.64.0810111057030.4425@axis700.grange>
	<87k5cfoz7b.fsf@macbook.be.48ers.dk>
	<Pine.LNX.4.64.0810112309410.4965@axis700.grange>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacmet@sunsite.dk, Steve.Glendinning@smsc.com,
	netdev@vger.kernel.org, Ian.Saturley@smsc.com
To: lg@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54963
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754620AbYJKWIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 18:08:20 -0400
In-Reply-To: <Pine.LNX.4.64.0810112309410.4965@axis700.grange>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guennadi Liakhovetski <lg@denx.de>
Date: Sat, 11 Oct 2008 23:10:58 +0200 (CEST)

> If an external PHY is found the driver falls through to the default
> case in the switch and overwrites the PHY ID. Add the missing break.
> 
> Signed-off-by: Guennadi Liakhovetski <lg@denx.de>

Applied, thanks.

> against 2.6.27

Luckily this still applied cleanly :)
