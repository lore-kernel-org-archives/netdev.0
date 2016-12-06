From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] phy: add phy fixup unregister functions
Date: Tue, 06 Dec 2016 10:01:04 -0500 (EST)
Message-ID: <20161206.100104.1134856835372946560.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D40975526@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, andrew@lunn.ch, netdev@vger.kernel.org
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41212 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751576AbcLFPBG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 10:01:06 -0500
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40975526@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Woojung.Huh@microchip.com>
Date: Fri, 2 Dec 2016 23:04:13 +0000

> From: Woojung Huh <woojung.huh@microchip.com>
> 
> Add functions to unregister phy fixup for modules.
> 
> phy_unregister_fixup(const char *bus_id, u32 phy_uid, u32 phy_uid_mask)
>  Unregister phy fixup matches bus_id, phy_uid and phy_uid_mask
>  from phy_fixup_list.
>  Return 0 when find matched one and remove from the list.
>  Return -ENODEV when fail to find it on the list.
> 
> phy_unregister_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask)
>  Unregister phy fixup from phy_fixup_list.
>  Use it for fixup registered by phy_register_fixup_for_uid()
>  Return 0 when find matched one and remove from the list.
>  Return -ENODEV when fail to find it on the list.
> 
> phy_unregister_fixup_for_id(const char *bus_id)
>  Unregister phy fixup from phy_fixup_list.
>  Use it for fixup registered by phy_register_fixup_for_id()
>  Return 0 when find matched one and remove from the list.
>  Return -ENODEV when fail to find it on the list.
> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>

Please submit this along with whatever will be the first user(s) of these
new interfaces.
