From: David Miller <davem@davemloft.net>
Subject: Re: [NET-2.6.24][VETH][patch 1/1] fix bad netif_carrier_off place
Date: Wed, 19 Sep 2007 09:48:49 -0700 (PDT)
Message-ID: <20070919.094849.31235236.davem@davemloft.net>
References: <20070919133821.495385952@mai.toulouse-stg.fr.ibm.com>
	<20070919140850.607582917@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39209
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756638AbXISQtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 12:49:06 -0400
In-Reply-To: <20070919140850.607582917@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: dlezcano@fr.ibm.com
Date: Wed, 19 Sep 2007 15:38:22 +0200

> From: Daniel Lezcano <dlezcano@fr.ibm.com>
> 
> If the netif_carrier_off is called before register_netdev
> that will use and generate an event for a non initialized network
> device and that leads to a Oops.
> 
> I moved the netif_carrier_off from the setup function after each 
> register_netdev call.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied, thanks.
