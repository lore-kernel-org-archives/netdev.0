From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net phy: Check for aneg completion before setting
 state to PHY_RUNNING
Date: Fri, 02 May 2014 15:51:25 -0400 (EDT)
Message-ID: <20140502.155125.1401943315194446355.davem@davemloft.net>
References: <53587C7F.2000808@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: kumaran.4353@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36982 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752584AbaEBTv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 15:51:26 -0400
In-Reply-To: <53587C7F.2000808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balakumaran Kannan <kumaran.4353@gmail.com>
Date: Thu, 24 Apr 2014 08:22:47 +0530

> phy_state_machine should check whether auto-negotiatin is completed
> before changing phydev->state from PHY_NOLINK to PHY_RUNNING. If
> auto-negotiation is not completed phydev->state should be set to
> PHY_AN.
> 
> Signed-off-by: Balakumaran Kannan <kumaran.4353@gmail.com>

Applied, thanks.
