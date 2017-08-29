From: Kishon Vijay Abraham I <kishon@ti.com>
Subject: Re: [PATCH net-next v3 01/13] phy: add sgmii and 10gkr modes to the
 phy_mode enum
Date: Tue, 29 Aug 2017 16:08:29 +0530
Message-ID: <4c66e79f-d385-3cf5-6f24-2a4aec9fb3b4@ti.com>
References: <20170828145725.2539-1-antoine.tenart@free-electrons.com>
 <20170828145725.2539-2-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <thomas.petazzoni@free-electrons.com>, <nadavh@marvell.com>,
        <linux@armlinux.org.uk>, <linux-kernel@vger.kernel.org>,
        <mw@semihalf.com>, <stefanc@marvell.com>,
        <miquel.raynal@free-electrons.com>, <netdev@vger.kernel.org>
To: Antoine Tenart <antoine.tenart@free-electrons.com>,
        <davem@davemloft.net>, <andrew@lunn.ch>, <jason@lakedaemon.net>,
        <sebastian.hesselbarth@gmail.com>,
        <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170828145725.2539-2-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Monday 28 August 2017 08:27 PM, Antoine Tenart wrote:
> This patch adds more generic PHY modes to the phy_mode enum, to
> allow configuring generic PHYs to the SGMII and/or the 10GKR mode
> by using the set_mode callback.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>

Acked-by: Kishon Vijay Abraham I <kishon@ti.com>
> ---
>  include/linux/phy/phy.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/include/linux/phy/phy.h b/include/linux/phy/phy.h
> index 78bb0d7f6b11..e694d4008c4a 100644
> --- a/include/linux/phy/phy.h
> +++ b/include/linux/phy/phy.h
> @@ -27,6 +27,8 @@ enum phy_mode {
>  	PHY_MODE_USB_HOST,
>  	PHY_MODE_USB_DEVICE,
>  	PHY_MODE_USB_OTG,
> +	PHY_MODE_SGMII,
> +	PHY_MODE_10GKR,
>  };
>  
>  /**
> 
