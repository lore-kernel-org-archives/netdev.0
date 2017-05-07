From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next 2/5] phy: micrel: add Microchip KSZ 9477 Switch
 PHY support
Date: Sun, 7 May 2017 01:02:31 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40A5C2CA@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D40A5BFF6@CHN-SV-EXMX02.mchp-main.com>,<20170506035021.GB14749@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <f.fainelli@gmail.com>, <vivien.didelot@savoirfairelinux.com>,
        <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <UNGLinuxDriver@microchip.com>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa1.microchip.iphmx.com ([68.232.147.91]:20274 "EHLO
        esa1.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752600AbdEGWYm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 7 May 2017 18:24:42 -0400
In-Reply-To: <20170506035021.GB14749@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +}, {
>> +     .phy_id         = PHY_ID_KSZ9477,
>> +     .phy_id_mask    = MICREL_PHY_ID_MASK,
>> +     .name           = "Microchip KSZ9477",
>> +     .features       = PHY_GBIT_FEATURES,
>> +     .flags          = PHY_HAS_MAGICANEG,
>
>Is this magic still used anywhere? I could not find anything.
>
Hi Andrew,

Really no usage in define and flags.
Will double check and remove it.

- Woojung
