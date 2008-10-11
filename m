From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smc911x: Add support for LAN921{5,7,8} chips from SMSC
Date: Sat, 11 Oct 2008 15:08:52 -0700 (PDT)
Message-ID: <20081011.150852.73771267.davem@davemloft.net>
References: <Pine.LNX.4.64.0810111057030.4425@axis700.grange>
	<87k5cfoz7b.fsf@macbook.be.48ers.dk>
	<Pine.LNX.4.64.0810112311030.4965@axis700.grange>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacmet@sunsite.dk, Steve.Glendinning@smsc.com,
	netdev@vger.kernel.org, Ian.Saturley@smsc.com
To: lg@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54971
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750794AbYJKWJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 18:09:16 -0400
In-Reply-To: <Pine.LNX.4.64.0810112311030.4965@axis700.grange>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guennadi Liakhovetski <lg@denx.de>
Date: Sat, 11 Oct 2008 23:13:30 +0200 (CEST)

> LAN92{5,7,8} chips from SMSC are register compatible with LAN911{5,6,7,8}
> controllers, and only add support for HP Auto-MDIX. LAN9218 doesn't have
> an external MII interface. Also fixes a couple of minor style issues.
> 
> Signed-off-by: Guennadi Liakhovetski <lg@denx.de>

This patch mixes multiple changes, please split it up into multiple
patches.

Coding style changes in one changeset, debugging output adjustment
in another, and the new chipset support in yet another patch.

Thanks.
