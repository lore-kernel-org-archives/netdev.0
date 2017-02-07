From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 3/3] net: phy: dp83867: Recover from "port
 mirroring" N/A MODE4
Date: Tue, 07 Feb 2017 13:59:53 -0500 (EST)
Message-ID: <20170207.135953.1084828979443093909.davem@davemloft.net>
References: <1486444824-12733-1-git-send-email-lukma@denx.de>
        <1486444824-12733-2-git-send-email-lukma@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, m-karicheri2@ti.com,
        linux-kernel@vger.kernel.org, eric@engestrom.ch, andrew@lunn.ch,
        netdev@vger.kernel.org, kishon@ti.com, grygorii.strashko@ti.com
To: lukma@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54902 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755381AbdBGS7z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 13:59:55 -0500
In-Reply-To: <1486444824-12733-2-git-send-email-lukma@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lukasz Majewski <lukma@denx.de>
Date: Tue,  7 Feb 2017 06:20:24 +0100

> The DP83867 when not properly bootstrapped - especially with LED_0 pin -
> can enter N/A MODE4 for "port mirroring" feature.
> 
> To provide normal operation of the PHY, one needs not only to explicitly
> disable the port mirroring feature, but as well stop some IC internal
> testing (which disables RGMII communication).
> 
> To do that the STRAP_STS1 (0x006E) register must be read and RESERVED bit
> 11 examined. When it is set, the another RESERVED bit (11) at PHYCR
> (0x0010) register must be clear to disable testing mode and enable RGMII
> communication.
> 
> Thorough explanation of the problem can be found at following e2e thread:
> "DP83867IR: Problem with RESERVED bits in PHY Control Register (PHYCR) -
> Linux driver"
> 
> https://e2e.ti.com/support/interface/ethernet/f/903/p/571313/2096954#2096954
> 
> Signed-off-by: Lukasz Majewski <lukma@denx.de>
> ---
> Changes for v3:
> - None

Applied.
