From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] net: phy: micrel: Fix regression in kszphy_probe
Date: Tue, 12 May 2015 23:19:09 -0400 (EDT)
Message-ID: <20150512.231909.896139778564783277.davem@davemloft.net>
References: <1431416594-7758-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, festevam@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, johan@kernel.org, niklass@axis.com,
	stable@vger.kernel.org
To: niklas.cassel@axis.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431416594-7758-1-git-send-email-niklass@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>
Date: Tue, 12 May 2015 09:43:14 +0200

> Don't do clock-mode-select if clk == NULL,
> since when building without CONFIG_HAVE_CLK,
> clk_get returns NULL and clk_get_rate returns 0.
> 
> Doing clock-mode-select in this cause causes kszphy_probe to
> return -EINVAL and thus prevents the device from being probed.
> 
> The original code (before regression) would return 0
> when building without CONFIG_HAVE_CLK.
> 
> Cc: stable <stable@vger.kernel.org> # 3.18+
> Fixes: 1fadee0c3645 ("net/phy: micrel: Add clock support for
> KSZ8021/KSZ8031")
> Reviewed-by: Fabio Estevam <fabio.estevam@freescale.com>
> Reviewed-by: Johan Hovold <johan@kernel.org>
> Signed-off-by: Niklas Cassel <niklass@axis.com>

Applied, thank you.
