From: "David.Wu" <david.wu@rock-chips.com>
Subject: Re: [PATCH 01/11] net: phy: Add rockchip phy driver support
Date: Tue, 27 Jun 2017 22:44:10 +0800
Message-ID: <38394157-adae-3476-55f3-ab5838744033@rock-chips.com>
References: <1498192929-7519-1-git-send-email-david.wu@rock-chips.com>
 <1498192929-7519-2-git-send-email-david.wu@rock-chips.com>
 <20170624021910.GB4875@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=gbk; format=flowed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, heiko@sntech.de, robh+dt@kernel.org,
        mark.rutland@arm.com, catalin.marinas@arm.com, will.deacon@arm.com,
        olof@lixom.net, linux@armlinux.org.uk, arnd@arndb.de,
        f.fainelli@gmail.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, huangtao@rock-chips.com,
        hwg@rock-chips.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lucky1.263xmail.com ([211.157.147.134]:41457 "EHLO
        lucky1.263xmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751776AbdF0Ood (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 10:44:33 -0400
In-Reply-To: <20170624021910.GB4875@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

ÔÚ 2017/6/24 10:19, Andrew Lunn Ð´µÀ:
> On Fri, Jun 23, 2017 at 12:41:59PM +0800, David Wu wrote:
>> Support internal ephy currently.
>>
>> Signed-off-by: David Wu <david.wu@rock-chips.com>
>> ---
>>   drivers/net/phy/Kconfig    |  4 ++
>>   drivers/net/phy/Makefile   |  1 +
>>   drivers/net/phy/rockchip.c | 94 ++++++++++++++++++++++++++++++++++++++++++++++
>>   3 files changed, 99 insertions(+)
>>   create mode 100644 drivers/net/phy/rockchip.c
>>
>> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
>> index c360dd6..86010d4 100644
>> --- a/drivers/net/phy/Kconfig
>> +++ b/drivers/net/phy/Kconfig
>> @@ -350,6 +350,10 @@ config XILINX_GMII2RGMII
>>            the Reduced Gigabit Media Independent Interface(RGMII) between
>>            Ethernet physical media devices and the Gigabit Ethernet controller.
>>   
>> +config ROCKCHIP_MAC_PHY
> 
> This is a bit of an odd name, having both MAC and PHY in it. Are there
> any other RockChip PHYs? Any external PHYS? Are they register
> incompatible with the internal PHY?  Is it even RockChip IP? Or has it
> been licensed from somebody else?
> 

Maybe I just want to highlight it applies to the PHY with Mac 
connection, actually I was named Rockchip at the beginning, as Heiko 
said, PHY is a wide range, so add a modifier to restrict it.

Yes, we use other external phys, like realtek and etc...

If we have any other phy in our socs, it also could be expanded at 
rockchip_phy_tbl{} at rockchip.c

it has been licensed from somebody.

> I would more likely just call it ROCKCHIP_PHY.
> 
>    Andrew
> 
> 
> 
