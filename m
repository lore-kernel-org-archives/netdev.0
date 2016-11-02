From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [RFC PATCH v2 2/5] net: phy: Add Meson GXL Internal PHY driver
Date: Wed, 2 Nov 2016 11:33:18 +0100
Message-ID: <32b06712-fc7c-ff00-9af7-aba3405c9d98@baylibre.com>
References: <1477932987-27871-1-git-send-email-narmstrong@baylibre.com>
 <1477932987-27871-3-git-send-email-narmstrong@baylibre.com>
 <20161031190558.GK9441@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, khilman@baylibre.com, carlo@caione.org,
        netdev@vger.kernel.org, linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:38577 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751752AbcKBKdW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 06:33:22 -0400
Received: by mail-wm0-f41.google.com with SMTP id n67so27553066wme.1
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 03:33:21 -0700 (PDT)
In-Reply-To: <20161031190558.GK9441@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/2016 08:05 PM, Andrew Lunn wrote:
> On Mon, Oct 31, 2016 at 05:56:24PM +0100, Neil Armstrong wrote:
>> Add driver for the Internal RMII PHY found in the Amlogic Meson GXL SoCs.
>>
>> This PHY seems to only implement some standard registers and need some
>> workarounds to provide autoneg values from vendor registers.
>>
>> Some magic values are currently used to configure the PHY, and this a
>> temporary setup until clarification about these registers names and
>> registers fields are provided by Amlogic.
>>
>> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
>> ---
>>  drivers/net/phy/Kconfig     |  5 +++
>>  drivers/net/phy/Makefile    |  1 +
>>  drivers/net/phy/meson-gxl.c | 81 +++++++++++++++++++++++++++++++++++++++++++++
>>  3 files changed, 87 insertions(+)
>>  create mode 100644 drivers/net/phy/meson-gxl.c
>>
>> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
>> index 2651c8d..09342b6 100644
>> --- a/drivers/net/phy/Kconfig
>> +++ b/drivers/net/phy/Kconfig
>> @@ -226,6 +226,11 @@ config DP83867_PHY
>>  	---help---
>>  	  Currently supports the DP83867 PHY.
>>  
>> +config MESON_GXL_PHY
>> +	tristate "Amlogic Meson GXL Internal PHY"
>> +	---help---
>> +	  Currently has a driver for the Amlogic Meson GXL Internal PHY
>> +
> 
> Hi Neil
> 
> Please keep them in alphabetic order. This goes after Marvell.
> 
>>  config FIXED_PHY
>>  	tristate "MDIO Bus/PHY emulation with fixed speed/link PHYs"
>>  	depends on PHYLIB
>> diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
>> index e58667d..1511b3e 100644
>> --- a/drivers/net/phy/Makefile
>> +++ b/drivers/net/phy/Makefile
>> @@ -44,6 +44,7 @@ obj-$(CONFIG_MARVELL_PHY)	+= marvell.o
>>  obj-$(CONFIG_MICREL_KS8995MA)	+= spi_ks8995.o
>>  obj-$(CONFIG_MICREL_PHY)	+= micrel.o
>>  obj-$(CONFIG_MICROCHIP_PHY)	+= microchip.o
>> +obj-$(CONFIG_MESON_GXL_PHY)	+= meson-gxl.o
>>  obj-$(CONFIG_MICROSEMI_PHY)	+= mscc.o
> 
> Again, alphabetic order.
> 
>        Andrew
> 

Sorry, rebase issue.

Neil
