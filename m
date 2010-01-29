From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] cdc_ether: Partially revert "usbnet: Set link
 down initially ..."
Date: Thu, 28 Jan 2010 21:37:33 -0800 (PST)
Message-ID: <20100128.213733.71104817.davem@davemloft.net>
References: <wnS54-l8PVO.A.TlF.oMlSLB@chimera>
	<omZ8aBZReyD.A.rz.COlSLB@chimera>
	<1264720725.373.550.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, avi.rozen@gmail.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45604
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750899Ab0A2FhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 00:37:21 -0500
In-Reply-To: <1264720725.373.550.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 28 Jan 2010 23:18:44 +0000

> Commit 37e8273cd30592d3a82bcb70cbb1bdc4eaeb6b71 ("usbnet: Set link down
> initially for drivers that update link state") changed the initial link
> state in cdc_ether and other drivers based on the understanding that the
> devices they support generate link change interrupts.  However, this is
> optional in the CDC Ethernet protocol, and two users have reported in
> <http://bugzilla.kernel.org/show_bug.cgi?id=14791> that the link state
> for their devices remains down.  Therefore, revert the change in
> cdc_ether.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> Tested-by: Avi Rozen <avi.rozen@gmail.com>

Applied, thanks a lot Ben.
