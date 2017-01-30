From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] net: dsa: bcm_sf2: CFP support
Date: Mon, 30 Jan 2017 11:11:06 -0500 (EST)
Message-ID: <20170130.111106.805457012223071538.davem@davemloft.net>
References: <20170129031325.21911-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cphealy@gmail.com,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54510 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932130AbdA3QUv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 11:20:51 -0500
In-Reply-To: <20170129031325.21911-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sat, 28 Jan 2017 19:13:21 -0800

> This patch series adds support for the Broadcom Compact Field Processor (CFP)
> which is a classification and matching engine built into most Broadcom switches.
> 
> We support that using ethtool::rxnfc because it allows all known uses cases from
> the users I support to work, and more importantly, it allows the selection of a
> target rule index, which is later used by e.g: offloading hardware, this is an
> essential feature that I could not find being supported with cls_* for instance.
> 
> Thanks!
> 
> Changes in v2:
> 
> - fixed modular builds reported by kbuild test robot

Series applied, thanks Florian.
