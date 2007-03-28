From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] bridge: don't route packets while learning
Date: Tue, 27 Mar 2007 19:18:10 -0700 (PDT)
Message-ID: <20070327.191810.45515645.davem@davemloft.net>
References: <20070320141251.3760d87f@dxpl.pdx.osdl.net>
	<20070320141552.53d39130@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44596
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933464AbXC1CSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 22:18:11 -0400
In-Reply-To: <20070320141552.53d39130@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 20 Mar 2007 14:15:52 -0700

> While in the STP learning state, don't route packets; wait until
> forwarding delay has expired. The purpose of the forwarding delay
> is to detect loops in the network, and if a brouter started up
> and started forwarding, it could cause a flood.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Also applied to net-2.6.22

Thanks Stephen.
