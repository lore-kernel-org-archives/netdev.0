From: "David.Wu" <david.wu@rock-chips.com>
Subject: Re: [PATCH v3 01/11] net: phy: Add rockchip phy driver support
Date: Wed, 9 Aug 2017 15:01:16 +0800
Message-ID: <4cfa1cbc-d3a9-d27a-ecd3-2285d6e498a7@rock-chips.com>
References: <1501654546-17292-1-git-send-email-david.wu@rock-chips.com>
 <1501654546-17292-2-git-send-email-david.wu@rock-chips.com>
 <20170802132121.GA24708@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=gbk; format=flowed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, heiko@sntech.de, f.fainelli@gmail.com,
        robh+dt@kernel.org, mark.rutland@arm.com, catalin.marinas@arm.com,
        will.deacon@arm.com, olof@lixom.net, linux@armlinux.org.uk,
        arnd@arndb.de, peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, hwg@rock-chips.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170802132121.GA24708@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

ÔÚ 2017/8/2 21:21, Andrew Lunn Ð´µÀ:
>> +static struct phy_driver rockchip_phy_driver[] = {
>> +{
>> +	.phy_id			= 0x1234d400,
>> +	.phy_id_mask		= 0xfffffff0,
>> +	.name			= "Rockchip internal EPHY",
>> +	.features		= (PHY_BASIC_FEATURES | SUPPORTED_Pause
>> +				   | SUPPORTED_Asym_Pause),
> 
> Please take a look at Documentation/networking/phy.txt and
> Fixes: 529ed1275263 ("net: phy: phy drivers should not set SUPPORTED_[Asym_]Pause")
> 
> Pause frames / flow control
> 
>   The PHY does not participate directly in flow control/pause frames except by
>   making sure that the SUPPORTED_Pause and SUPPORTED_AsymPause bits are set in
>   MII_ADVERTISE to indicate towards the link partner that the Ethernet MAC
>   controller supports such a thing. Since flow control/pause frames generation
>   involves the Ethernet MAC driver, it is recommended that this driver takes care
>   of properly indicating advertisement and support for such features by setting
>   the SUPPORTED_Pause and SUPPORTED_AsymPause bits accordingly. This can be done
>   either before or after phy_connect() and/or as a result of implementing the
>   ethtool::set_pauseparam feature.
> 

Thanks for the reminder, I'll remove it.

> 	Andrew
> 
> 
> 
