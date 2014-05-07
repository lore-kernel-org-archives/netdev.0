From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mdio: of_mdiobus_register(): fall back to
 mdiobus_register() for !CONFIG_OF
Date: Wed, 07 May 2014 17:16:51 -0400 (EDT)
Message-ID: <20140507.171651.445446700464386722.davem@davemloft.net>
References: <1399395136-12139-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, mugunthanvnm@ti.com, netdev@vger.kernel.org
To: zonque@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51995 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbaEGVQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 17:16:54 -0400
In-Reply-To: <1399395136-12139-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <zonque@gmail.com>
Date: Tue,  6 May 2014 18:52:16 +0200

> If CONFIG_OF is not set, make of_mdiobus_register() call
> mdiobus_register() instead of returning -ENOSYS.
> 
> This way, we can just call of_mdiobus_register() from all DT-enabled
> drivers to handle the compat cases.
> 
> Signed-off-by: Daniel Mack <zonque@gmail.com>
> Suggested-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Daniel.
