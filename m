From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibm_newemac: emac_close() needs to call
 netif_carrier_off()
Date: Thu, 20 Aug 2009 02:21:38 -0700 (PDT)
Message-ID: <20090820.022138.221328122.davem@davemloft.net>
References: <20090819210000.D56AB254211@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41489
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753419AbZHTJV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 05:21:26 -0400
In-Reply-To: <20090819210000.D56AB254211@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Wed, 19 Aug 2009 14:00:00 -0700 (PDT)

> When ibm_newemac netdev instance is shutdown with "ifconfig down",
> the netdev interface does not go properly down. netif_carrier_ok()
> keeps returning TRUE even after "ifconfig down".
> 
> The problem can be seen when ibm_newemac instances are slaves of
> a bonding interface. The bonding interface code uses netif_carrier_ok()
> to determine the link status of its slaves. When ibm_newemac slave is
> shutdown with "ifconfig down", the bonding interface won't detect any
> link status change because netif_carrier_ok() keeps returning TRUE.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Applied, thanks.
