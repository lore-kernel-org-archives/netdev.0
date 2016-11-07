From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 0/7] add NS2 support to bgmac
Date: Mon, 07 Nov 2016 13:11:41 -0500 (EST)
Message-ID: <20161107.131141.526803424224367244.davem@davemloft.net>
References: <1478236262-3351-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, mark.rutland@arm.com, f.fainelli@gmail.com,
        rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: jon.mason@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478236262-3351-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jon Mason <jon.mason@broadcom.com>
Date: Fri,  4 Nov 2016 01:10:55 -0400

> Changes in v6:
> * Use a common bgmac_phy_connect_direct (per Rafal Milecki) 
> * Rebased on latest net-next
> * Added Reviewed-by to the relevant patches
> 
> 
> Changes in v5:
> * Change a pr_err to netdev_err (per Scott Branden)
> * Reword the lane swap binding documentation (per Andrew Lunn)
> 
> 
> Changes in v4:
> * Actually send out the lane swap binding doc patch (Per Scott Branden)
> * Remove unused #define (Per Andrew Lunn)
> 
> 
> Changes in v3:
> * Clean-up the bgmac DT binding doc (per Rob Herring)
> * Document the lane swap binding and make it generic (Per Andrew Lunn)
> 
> 
> Changes in v2:
> * Remove the PHY power-on (per Andrew Lunn)
> * Misc PHY clean-ups regarding comments and #defines (per Andrew Lunn)
>   This results on none of the original PHY code from Vikas being
>   present.  So, I'm removing him as an author and giving him
>   "Inspired-by" credit.
> * Move PHY lane swapping to PHY driver (per Andrew Lunn and Florian
>   Fainelli)
> * Remove bgmac sleep (per Florian Fainelli)
> * Re-add bgmac chip reset (per Florian Fainelli and Ray Jui)
> * Rebased on latest net-next
> * Added patch for bcm54xx_auxctl_read, which is used in the BCM54810

Series applied, thanks.
