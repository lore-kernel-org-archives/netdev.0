From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] MDIO bus reset GPIO cleanups
Date: Tue, 13 Jun 2017 13:00:59 -0400 (EDT)
Message-ID: <20170613.130059.891454430682161684.davem@davemloft.net>
References: <20170612205537.977289294@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, robh+dt@kernel.org,
        frowand.list@gmail.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44634 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753636AbdFMRBB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 13:01:01 -0400
In-Reply-To: <20170612205537.977289294@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Mon, 12 Jun 2017 23:55:37 +0300

> Commit 4c5e7a2c0501 ("dt-bindings: mdio: Clarify binding document")
> declared that a MDIO reset GPIO property should have only a single GPIO
> reference/specifier, however the supporting code was left intact...
> Here's a couple of the obvious cleanups to that code:
> 
> [1/2] mdio_bus: handle only single PHY reset GPIO
> [2/2] mdio_bus: use devm_gpiod_get_optional()

Series applied.
