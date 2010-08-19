From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 1/2] bnx2x: Fix PHY locking problem
Date: Wed, 18 Aug 2010 23:41:31 -0700 (PDT)
Message-ID: <20100818.234131.91330479.davem@davemloft.net>
References: <1281976446.3997.17.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yaniv.home@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52057
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751066Ab0HSGlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 02:41:12 -0400
In-Reply-To: <1281976446.3997.17.camel@lb-tlvb-yanivr.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yaniv Rosner" <yaniv.home@broadcom.com>
Date: Mon, 16 Aug 2010 19:34:06 +0300

> PHY locking is required between two ports for some external PHYs. Since
> initialization was done in the common init function (called only on the 
> first port initialization) rather than in the port init function, there
> was in fact no PHY locking between the ports. 
> 
> Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 

Applied.
