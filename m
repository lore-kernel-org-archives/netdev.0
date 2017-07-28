From: "David.Wu" <david.wu@rock-chips.com>
Subject: Re: [PATCH v2 01/11] net: phy: Add rockchip phy driver support
Date: Fri, 28 Jul 2017 16:19:52 +0800
Message-ID: <c92ffbe9-dfb0-0fd7-680d-699c31902534@rock-chips.com>
References: <1501160156-30328-1-git-send-email-david.wu@rock-chips.com>
 <1501160156-30328-2-git-send-email-david.wu@rock-chips.com>
 <807c43ee-8421-c0b3-8aea-6091bef07a4c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, hwg@rock-chips.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        heiko@sntech.de, andrew@lunn.ch, robh+dt@kernel.org,
        mark.rutland@arm.com, catalin.marinas@arm.com, will.deacon@arm.com,
        olof@lixom.net, linux@armlinux.org.uk, arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from lucky1.263xmail.com ([211.157.147.135]:54850 "EHLO
        lucky1.263xmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751007AbdG1IUC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 04:20:02 -0400
In-Reply-To: <807c43ee-8421-c0b3-8aea-6091bef07a4c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

在 2017/7/28 0:51, Florian Fainelli 写道:
>> +}
>> +
>> +static int rockchip_internal_phy_config_init(struct phy_device *phydev)
>> +{
>> +	int val;
>> +
>> +	/*
>> +	 * The auto MIDX has linked problem on some board,
>> +	 * workround to disable auto MDIX.
>> +	 */
> If this a board-specific problem you may consider register a PHY fixup
> for the affected boards, or introduce a specific property to illustrate
> that MDI-X is broken.

You mean is that if I need disable Auto-mdix, then I'm going to add a 
property to DTS, from here to decide whether or not to close Auto-mdix?

> 
