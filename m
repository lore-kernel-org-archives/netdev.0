From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 0/4] net: phy: Register header file for Microsemi PHYs.
Date: Wed, 24 Aug 2016 14:45:26 +0200
Message-ID: <20160824124526.GA13406@lunn.ch>
References: <646450A91FAED74E85C6E9C4D6E936A14533665A@avsrvexchmbx1.microsemi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        Allan Nielsen <Allan.Nielsen@microsemi.com>
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43254 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753488AbcHXMqR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 Aug 2016 08:46:17 -0400
Content-Disposition: inline
In-Reply-To: <646450A91FAED74E85C6E9C4D6E936A14533665A@avsrvexchmbx1.microsemi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2016 at 11:58:01AM +0000, Raju Lakkaraju wrote:
> From: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> This is Microsemi's VSC 85xx PHY register definitions header file.

Hi Raju

Patch [0/X] is the cover note. It should contain an overview of the
patch series and why this patch series is needed. It should not
contain a patch itself.

Also, the 5 patches have not been threaded together. Did you send them
with a single git send-email command, or 5 individual commands? By
default, using a single command should cause them to be threaded.

	 Andrew

> 
> Signed-off-by: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> ---
>  drivers/net/phy/mscc_reg.h | 135 +++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 135 insertions(+)
>  create mode 100644 drivers/net/phy/mscc_reg.h
> 
> diff --git a/drivers/net/phy/mscc_reg.h b/drivers/net/phy/mscc_reg.h
> new file mode 100644
> index 0000000..ddb825c
> --- /dev/null
> +++ b/drivers/net/phy/mscc_reg.h
> @@ -0,0 +1,135 @@
> +/*
> + * Driver for Microsemi VSC85xx PHYs
> + *
> + * Author: Nagaraju Lakkaraju
> + * License: Dual MIT/GPL
> + * Copyright (c) 2016 Microsemi Corporation
> + */
> +
> +#ifndef __MSCC_REG_H
> +#define __MSCC_REG_H
> +
> +/* Microsemi VSC85xx PHY registers */
> +/* IEEE 802. Std Registers */
> +#define MSCC_PHY_BYPASS_CONTROL        18
> +#define DISABLE_HP_AUTO_MDIX_MASK      0x0080
> +#define DISABLE_PAIR_SWAP_CORR_MASK    0x0020
> +#define DISABLE_POLARITY_CORR_MASK     0x0010
> +
> +#define MSCC_PHY_EXT_PHY_CNTL_1        23
> +#define MAC_IF_SELECTION_MASK          0x1800
> +#define MAC_IF_SELECTION_GMII          0
> +#define MAC_IF_SELECTION_RMII          1
> +#define MAC_IF_SELECTION_RGMII         2
> +#define MAC_IF_SELECTION_POS           11
> +#define FAR_END_LOOPBACK_MODE_MASK     0x0008
> +
> +#define MSCC_PHY_EXT_PHY_CNTL_2        24
> +#define CONNECTOR_LOOPBACK_MASK        0x0001
> +#define JUMBO_PACKET_MODE_MASK         0x0030
> +#define JUMBO_PACKET_MODE_POS          4
> +
> +#define MII_VSC85XX_INT_MASK           25
> +#define MII_VSC85XX_INT_MASK_MDINT     0x8000
> +#define MII_VSC85XX_INT_MASK_SPEED     0x4000
> +#define MII_VSC85XX_INT_MASK_LINK      0x2000
> +#define MII_VSC85XX_INT_MASK_DUPLEX    0x1000
> +#define MII_VSC85XX_INT_MASK_ANEG_ERR  0x0800
> +#define MII_VSC85XX_INT_MASK_ANEG_COM  0x0400
> +#define MII_VSC85XX_INT_MASK_POE       0x0200
> +#define MII_VSC85XX_INT_MASK_SYM       0x0100
> +#define MII_VSC85XX_INT_MASK_FLF       0x0080
> +#define MII_VSC85XX_INT_MASK_WOL       0x0040
> +#define MII_VSC85XX_INT_MASK_EXT       0x0020
> +#define MII_VSC85XX_INT_MASK_RESV      0x0010
> +#define MII_VSC85XX_INT_MASK_FCI       0x0008
> +#define MII_VSC85XX_INT_MASK_LDI       0x0004
> +#define MII_VSC85XX_INT_MASK_MSE       0x0002
> +#define MII_VSC85XX_INT_MASK_RX_ER     0x0001
> +#define MII_VSC85XX_INT_MASK_MASK      0xa000
> +
> +#define MII_VSC85XX_INT_STATUS         26
> +#define MSCC_PHY_DEV_AUX_CNTL          28
> +#define HP_AUTO_MDIX_X_OVER_IND_MASK   0x2000
> +#define ACTIPHY_TIME_OUT_BIT_7         0x0080
> +#define ACTIPHY_TIME_OUT_BIT_2         0x0004
> +#define ACTIPHY_TIME_OUT_MASK          0x0084
> +#define ACTIPHY_MODE_ENT               0x0040
> +
> +#define MSCC_EXT_PAGE_ACCESS           31
> +#define MSCC_PHY_PAGE_STANDARD         0x0000 /* Standard registers */
> +#define MSCC_PHY_PAGE_EXTENDED         0x0001 /* Extended registers */
> +#define MSCC_PHY_PAGE_EXTENDED_2       0x0002 /* Extended registers - page 2 */
> +#define MSCC_PHY_PAGE_EXTENDED_3       0x0003 /* Extended registers - page 3 */
> +#define MSCC_PHY_PAGE_EXTENDED_4       0x0004 /* Extended registers - page 4 */
> +#define MSCC_PHY_PAGE_GPIO             0x0010 /* GPIO registers */
> +
> +/* Extended Page 1 Registers */
> +#define MSCC_PHY_EXT_MODE_CNTL         19
> +#define FORCE_MDI_CROSSOVER_MASK       0x000C
> +#define FORCE_MDI_CROSSOVER_NORMAL     0
> +#define FORCE_MDI_CROSSOVER_MDI        2
> +#define FORCE_MDI_CROSSOVER_MDIX       3
> +#define FORCE_MDI_CROSSOVER_POS        2
> +
> +#define MSCC_PHY_ACTIPHY_CNTL          20
> +#define ACTIPHY_SLEEP_TIMER_MASK       0x6000
> +#define ACTIPHY_SLEEP_TIMER_POS        13
> +#define ACTIPHY_WAKEUP_TIMER_MASK      0x1800
> +#define ACTIPHY_WAKEUP_TIMER_POS       11
> +#define LINK_SPD_DOWNSHIFT_EN          0x0010
> +#define LINK_SPD_DOWNSHIFT_CNTL_POS    2
> +#define LINK_SPD_DOWNSHIFT_CNTL_MASK   0x000C
> +
> +#define MSCC_PHY_POE_MISC              23
> +#define INLINE_POE_DETECTION           0x0400
> +#define INLINE_POE_STATUS_MASK         0x0300
> +#define INLINE_POE_STATUS_POS          8
> +
> +/* Extended Page 2 Registers */
> +#define MSCC_PHY_RGMII_CNTL            20
> +#define FLF2_ENABLE                    0x8000
> +#define SOF_ENABLE                     0x1000
> +#define RGMII_RX_CLK_DELAY_MASK        0x0070
> +#define RGMII_RX_CLK_DELAY_POS         4
> +
> +#define MSCC_PHY_WOL_LOWER_MAC_ADDR    21
> +#define MSCC_PHY_WOL_MID_MAC_ADDR      22
> +#define MSCC_PHY_WOL_UPPER_MAC_ADDR    23
> +#define MSCC_PHY_WOL_LOWER_PASSWD      24
> +#define MSCC_PHY_WOL_MID_PASSWD        25
> +#define MSCC_PHY_WOL_UPPER_PASSWD      26
> +
> +#define MSCC_PHY_WOL_MAC_CONTROL       27
> +#define EDGE_RATE_CNTL_POS             5
> +#define EDGE_RATE_CNTL_MASK            0x00E0
> +#define SECURE_ON_ENABLE               0x8000
> +#define SECURE_ON_PASSWD_LEN_4         0x4000
> +
> +#define MSCC_PHY_RING_RESI_CONTROL     30
> +#define RR_STARTUP_ENABLE              0x8000
> +#define RR_ADVERTISE_ENABLE            0x4000
> +#define RR_LP_ADVERTISE                0x2000
> +#define RR_FORCE_ENABLE                0x1000
> +#define RR_STATUS_MASK                 0x0030
> +#define RR_STATUS_POS                  4
> +
> +/* GPIO registers */
> +#define MSCC_GPIO_CONTROL_2            14
> +#define COMA_MODE_EN                   0x2000
> +#define COMA_MODE_OUTPUT               0x1000
> +#define COMA_MODE_INPUT                0x0800
> +
> +#define MSCC_RECOVERED_CLK_CONTROL     23
> +#define RCVRD_CLK_EN                   0x8000
> +#define CLK_FREQUENCY_SELECT_MASK      0x0700
> +#define CLK_SQUELCH_LVL_MASK           0x0030
> +#define CLK_SELECTION_MASK             0x0007
> +#define CLK_FREQUENCY_SELECT_POS       8
> +#define CLK_SQUELCH_LVL_POS            4
> +
> +/* Microsemi PHY ID's */
> +#define PHY_ID_VSC8531                 0x00070570
> +#define PHY_ID_VSC8541                 0x00070770
> +
> +#endif /* __MSCC_REG_H */
> -- 
> 2.7.4
> 
