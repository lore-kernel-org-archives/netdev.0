From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 0/3] add support for RGMII on GMAC0 through
 TRGMII hardware module
Date: Wed, 21 Sep 2016 20:17:00 -0700
Message-ID: <c7918b08-f641-c55b-eb1f-2b7e09d7a853@gmail.com>
References: <1474511636-11644-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: nbd@openwrt.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        andrew@lunn.ch, keyhaede@gmail.com, objelf@gmail.com
To: sean.wang@mediatek.com, john@phrozen.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474511636-11644-1-git-send-email-sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 21/09/2016 à 19:33, sean.wang@mediatek.com a écrit :
> From: Sean Wang <sean.wang@mediatek.com>
> 
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

Looks good to me:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks Sean!
-- 
Florian
