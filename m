From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26] CAN: use hrtimers in can-bcm protocol
Date: Tue, 15 Apr 2008 19:09:41 -0700 (PDT)
Message-ID: <20080415.190941.202291143.davem@davemloft.net>
References: <4805102A.8030707@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, kaber@trash.net, urs@isnogud.escape.de,
	netdev@vger.kernel.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44499
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753891AbYDPCJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 22:09:39 -0400
In-Reply-To: <4805102A.8030707@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Tue, 15 Apr 2008 22:29:30 +0200

> Make use of hrtimers to support high resolution capabilities, when 
> provided by the system clocksource.
> 
> The conversion to hrtimers additionally discovered and solved an 
> unlikely race condition that has been reproduced under (unrealistic) 
> massive receive load, which can only be produced on vcan software devices.
> 
> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>

Applied, thanks Oliver.
