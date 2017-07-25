From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ftgmac100: Make the MDIO bus a child of the
 ethernet device
Date: Mon, 24 Jul 2017 17:24:21 -0700 (PDT)
Message-ID: <20170724.172421.90770433856634318.davem@davemloft.net>
References: <1500879547.10674.63.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joel.stanley@au1.ibm.com
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45296 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755525AbdGYAYW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 20:24:22 -0400
In-Reply-To: <1500879547.10674.63.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Mon, 24 Jul 2017 16:59:07 +1000

> Populate mii_bus->parent with our own platform device before
> registering, which makes it easier to locate the MDIO bus
> in sysfs when trying to diagnose problems.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Applied.
