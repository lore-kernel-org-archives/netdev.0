From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/davinci_emac: fix failing PHY connect attempts
Date: Tue, 24 Apr 2012 00:44:31 -0400 (EDT)
Message-ID: <20120424.004431.314791552202975517.davem@davemloft.net>
References: <1335218803-8664-1-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: agust@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35413 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499Ab2DXEqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 00:46:38 -0400
In-Reply-To: <1335218803-8664-1-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anatolij Gustschin <agust@denx.de>
Date: Tue, 24 Apr 2012 00:06:43 +0200

> PHY connect attempts fail if no PHY id is specified in the emac platform
> data and another mdio bus has been registered before 'davinci_mdio' bus. In
> this case when configuring the interface, there will be an attempt to
> connect to already attached PHY on the previously registered mdio bus:
> 
> net eth1: PHY already attached
> net eth1: could not connect to phy smsc911x-0:01
> IP-Config: Failed to open eth1
> IP-Config: Device `eth1' not found
> 
> Fix this by modifying match_first_device() to match first PHY device
> on 'davinci_mdio' bus.
> 
> Signed-off-by: Anatolij Gustschin <agust@denx.de>

Applied, thanks.
