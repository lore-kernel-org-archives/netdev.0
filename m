From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH v4] net: phy: micrel: Fix regression in kszphy_probe
Date: Mon, 11 May 2015 17:38:22 +0200
Message-ID: <20150511153822.GA27224@localhost>
References: <1431357666-6808-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, festevam@gmail.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	johan@kernel.org, Niklas Cassel <niklass@axis.com>,
	stable <stable@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1431357666-6808-1-git-send-email-niklass@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 11, 2015 at 05:21:06PM +0200, Niklas Cassel wrote:
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
> 1fadee0c3645 ("net/phy: micrel: Add clock support for
> KSZ8021/KSZ8031")

Looks like you forgot the "Fixes: " tag itself when updating.

> Signed-off-by: Niklas Cassel <niklass@axis.com>

Look good otherwise, feel free to add my

Reviewed-by: Johan Hovold <johan@kernel.org>

when resending (unless David wants to fix it up himself).

Thanks,
Johan
