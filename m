From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: mdio-mux: Check return value of
 mdiobus_alloc()
Date: Mon, 14 Dec 2015 14:30:47 -0500 (EST)
Message-ID: <20151214.143047.997678276798238332.davem@davemloft.net>
References: <1450097511-13010-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59056 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbbLNTat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 14:30:49 -0500
In-Reply-To: <1450097511-13010-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Mon, 14 Dec 2015 13:51:51 +0100

> mdiobus_alloc() might return NULL, but its return value is not
> checked in mdio_mux_init(). This could potentially lead to a NULL
> pointer dereference. Fix it by checking the return value
> 
> Fixes: 0ca2997d1452 ("netdev/of/phy: Add MDIO bus multiplexer support.")
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied, thanks Tobias.
