From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: dsa: Mock-up driver
Date: Sat, 01 Apr 2017 12:40:01 -0700 (PDT)
Message-ID: <20170401.124001.1311060201990753496.davem@davemloft.net>
References: <20170331014321.3248-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57072 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751891AbdDATkE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 15:40:04 -0400
In-Reply-To: <20170331014321.3248-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 30 Mar 2017 18:43:21 -0700

> This patch adds support for a DSA mock-up driver which essentially does
> the following:
> 
> - registers/unregisters 4 fixed PHYs to the slave network devices
> - uses eth0 (configurable) as the master netdev
> - registers the switch as a fixed MDIO device against the fixed MDIO bus
>   at address 31
> - includes dynamic debug prints for dsa_switch_ops functions that can be
>   enabled to get call traces
> 
> This is a good way to test modular builds as well as exercise the DSA
> APIs without requiring access to real hardware. This does not test the
> data-path, although this could be added later on.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changes in v2;
> 
> - removed an unnecessary change to include/linux/fixed_phy.h

This looks extremely useful, applied, thanks!
