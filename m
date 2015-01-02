From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2][Nios2-dev] Altera TSE: Add missing phydev
Date: Fri, 02 Jan 2015 16:07:03 -0500 (EST)
Message-ID: <20150102.160703.2063675003050187496.davem@davemloft.net>
References: <BLU437-SMTP8237F72A0A7CCFCAF201F6B65E0@phx.gbl>
	<20150102.154500.2104526152897268790.davem@davemloft.net>
	<SNT146-W41ED8A3C5CE762B5F35C15B65D0@phx.gbl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nios2-dev@lists.rocketboards.org, netdev@vger.kernel.org
To: bkostya@hotmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53273 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbbABVHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 16:07:06 -0500
In-Reply-To: <SNT146-W41ED8A3C5CE762B5F35C15B65D0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kostya Belezko <bkostya@hotmail.com>
Date: Fri, 2 Jan 2015 15:57:29 -0500

> What do you mean by phy_disconnect() is down?
> Originally priv->phydev is NULL (and remains null forever) right after 'ifdown eth0'

I'm saying that the code should probably keep phydev non-NULL and just
take the PHY down/up during these events.
