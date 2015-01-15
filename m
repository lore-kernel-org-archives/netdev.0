From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: Fix addition of .trscer_err_mask to wrong SoC
 data
Date: Thu, 15 Jan 2015 14:09:53 -0500 (EST)
Message-ID: <20150115.140953.2021061170661876815.davem@davemloft.net>
References: <1421319139-22655-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, yoshihiro.shimoda.uh@renesas.com,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: geert+renesas@glider.be
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1421319139-22655-1-git-send-email-geert+renesas@glider.be>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert+renesas@glider.be>
Date: Thu, 15 Jan 2015 11:52:19 +0100

> commit b284fbe3b3ef9cf8 ("sh_eth: Fix access to TRSCER register") wanted
> to add a .trscer_err_mask value to the R-Car Gen2 family-specific data
> structure (r8a779x_data), but it was accidentally added to the
> SH7724-specific data structure (sh7724_data).
> 
> Presumably this happened due to a patch conflict with commit
> d407bc0203539031 ("sh-eth: Set fdr_value of R-Car SoCs"), which added
> another field at the same position.
> 
> Move the field setting to fix this.
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> Fixes: b284fbe3b3ef9cf8 ("sh_eth: Fix access to TRSCER register")

Oops, applied, thanks Geert.
