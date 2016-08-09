From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: phy: micrel: Add specific suspend
Date: Tue, 09 Aug 2016 16:19:56 -0700 (PDT)
Message-ID: <20160809.161956.2187735118267449721.davem@davemloft.net>
References: <1470378941-12387-1-git-send-email-wenyou.yang@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	alexandre.belloni@free-electrons.com, nicolas.ferre@atmel.com
To: wenyou.yang@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470378941-12387-1-git-send-email-wenyou.yang@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wenyou Yang <wenyou.yang@atmel.com>
Date: Fri, 5 Aug 2016 14:35:41 +0800

> Disable all interrupts when suspend, they will be enabled
> when resume. Otherwise, the suspend/resume process will be
> blocked occasionally.
> 
> Signed-off-by: Wenyou Yang <wenyou.yang@atmel.com>
> Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> ---
> 
> Changes in v2:
>  - Use fairly generic phydrv->config_intr() with
>    PHY_INTERRUPT_DISABLED, then call genphy_suspend().
>  - Modify kszphy_resume() with PHY_INTERRUPT_ENABLED accordingly.
>  - Add static attribute for kszphy_suspend().

Applied, thanks.
