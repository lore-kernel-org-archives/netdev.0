From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2][Nios2-dev] Altera TSE: Add missing phydev
Date: Fri, 02 Jan 2015 15:45:00 -0500 (EST)
Message-ID: <20150102.154500.2104526152897268790.davem@davemloft.net>
References: <BLU437-SMTP8237F72A0A7CCFCAF201F6B65E0@phx.gbl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nios2-dev@lists.rocketboards.org, netdev@vger.kernel.org
To: bkostya@hotmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52855 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888AbbABUpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 15:45:03 -0500
In-Reply-To: <BLU437-SMTP8237F72A0A7CCFCAF201F6B65E0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kostya Belezko <bkostya@hotmail.com>
Date: Tue, 30 Dec 2014 12:27:09 -0500

> Altera network device doesn't come up after
>  
> ifconfig eth0 down
> ifconfig eth0 up
>  
> The reason behind is clearing priv->phydev during tse_shutdown().
> The phydev is not restored back at tse_open().
> 
> Resubmiting as to follow Tobias Klauser suggestion.
> phy_start/phy_stop are called on each ifup/ifdown and
> phy_disconnect is called once during the module removal. 
> 
> Signed-off-by: Kostya Belezko <bkostya@hotmail.com>

I'll apply this, but I'm pretty sure the phy_disconnect() is down
so that the PHY is powered down when the device is not up.
