From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 2/6] net: phy: broadcom: Add BCM54810 PHY entry
Date: Tue, 1 Nov 2016 19:46:39 +0100
Message-ID: <20161101184639.GI10785@lunn.ch>
References: <1478022694-25308-1-git-send-email-jon.mason@broadcom.com>
 <1478022694-25308-3-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com, rafal@milecki.pl,
        linux-arm-kernel@lists.infradead.org
To: Jon Mason <jon.mason@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1478022694-25308-3-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jon

> @@ -56,6 +57,8 @@
>  #define PHY_BRCM_EXT_IBND_TX_ENABLE	0x00002000
>  #define PHY_BRCM_CLEAR_RGMII_MODE	0x00004000
>  #define PHY_BRCM_DIS_TXCRXC_NOENRGY	0x00008000
> +#define PHY_BRCM_EXP_LANE_SWAP		0x00010000
> +

You define this, but don't use it...

    Andrew
