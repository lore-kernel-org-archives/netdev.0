From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] net: ethernet: ti: cpsw: improve re-split policy
Date: Sat, 10 Dec 2016 17:30:25 -0500 (EST)
Message-ID: <20161210.173025.1084307097879882075.davem@davemloft.net>
References: <1481372630-14914-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481372630-14914-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Sat, 10 Dec 2016 14:23:45 +0200

> This patches add several simplifications and improvements to set
> maximum rate for channels taking in account switch and dual emac mode.
> 
> Don't re-split res in the following cases:
> - speed of phys is not changed
> - speed of phys is changed and no rate limited channels
> - speed of phys is changed and all channels are rate limited
> - phy is unlinked while dev is open
> - phy is linked back but speed is not changed
> 
> The maximum speed is sum of "linked" phys, thus res are split taken
> into account two interfaces, both for dual emac mode and for
> switch mode.
> 
> Tested on am572x
> 
> Based on net-next/master

Applied.
