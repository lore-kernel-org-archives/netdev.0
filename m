From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] add support for RGMII on GMAC0 through
 TRGMII hardware module
Date: Thu, 22 Sep 2016 08:22:47 -0400 (EDT)
Message-ID: <20160922.082247.198689057396545219.davem@davemloft.net>
References: <1474511636-11644-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, nbd@openwrt.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        andrew@lunn.ch, f.fainelli@gmail.com, keyhaede@gmail.com,
        objelf@gmail.com
To: sean.wang@mediatek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60032 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752016AbcIVMWw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 08:22:52 -0400
In-Reply-To: <1474511636-11644-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <sean.wang@mediatek.com>
Date: Thu, 22 Sep 2016 10:33:53 +0800

> By default, GMAC0 is connected to built-in switch called
> MT7530 through the proprietary interface called Turbo RGMII
> (TRGMII). TRGMII also supports well for RGMII as generic external
> PHY uses but requires some slight changes to the setup of TRGMII 
> and doesn't have well support on current driver.
> 
> So this patchset
> 1) provides the slight changes of the setup for RGMII can work
>    through TRGMII
> 2) adds additional setting "trgmii" as PHY_INTERFACE_MODE_TRGMII 
>    about phy-mode on device tree to make GMAC0 distinguish which
>    mode it runs
> 3) changes dynamically source clock, TX/RX delay and interface
>    mode on TRGMII for adapting various link
> 
> Changes since v1:
> - fixed the style of comment which doesn't have a space at 
>    the beginning and end of comment lines
> - add support for phy-mode "trgmii" as PHY_INTERFACE_MODE_TRGMII 
>    into linux/phy.h
> - enhance the Documentation about device tree binding for trgmii
>   which is applicable only for GMAC0 which uses fixed-link

Series applied.
