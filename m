From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 1/1] net: phy: bcm-phy-lib: Fix module license issue
Date: Thu, 15 Oct 2015 10:39:26 -0700
Message-ID: <561FE4CE.2030101@gmail.com>
References: <1444930633-23314-1-git-send-email-arunp@broadcom.com> <1444930633-23314-2-git-send-email-arunp@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com
To: Arun Parameswaran <arunp@broadcom.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444930633-23314-2-git-send-email-arunp@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/10/15 10:37, Arun Parameswaran wrote:
> The 'bcm-phy-lib.c', added as a part of the commit
> "net: phy: Add Broadcom phy library for common interfaces"
> was missing the module license. This was causing an issue
> when the library is built as a module; "module license
> 'unspecified' taints kernel".
> 
> This patch fixes the issue by adding the module license,
> author and description to the bcm-phy-lib.c file.
> 
> Fixes: a1cba5613edf5 ("net: phy: Add Broadcom phy library for
> common interfaces")

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> Signed-off-by: Arun Parameswaran <arunp@broadcom.com>
> ---
>  drivers/net/phy/bcm-phy-lib.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/net/phy/bcm-phy-lib.c b/drivers/net/phy/bcm-phy-lib.c
> index dd79ea6..ddb377e 100644
> --- a/drivers/net/phy/bcm-phy-lib.c
> +++ b/drivers/net/phy/bcm-phy-lib.c
> @@ -15,6 +15,7 @@
>  #include <linux/brcmphy.h>
>  #include <linux/export.h>
>  #include <linux/mdio.h>
> +#include <linux/module.h>
>  #include <linux/phy.h>
> 
>  #define MII_BCM_CHANNEL_WIDTH     0x2000
> @@ -206,3 +207,7 @@ int bcm_phy_enable_eee(struct phy_device *phydev)
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(bcm_phy_enable_eee);
> +
> +MODULE_DESCRIPTION("Broadcom PHY Library");
> +MODULE_LICENSE("GPL v2");
> +MODULE_AUTHOR("Broadcom Corporation");
> --
> 2.6.1
> 


-- 
Florian
