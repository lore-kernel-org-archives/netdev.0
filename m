From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] r8169: workaround for missing extended GigaMAC
 registers
Date: Fri, 07 Dec 2012 12:55:46 -0500 (EST)
Message-ID: <20121207.125546.1876404664623896418.davem@davemloft.net>
References: <20121205223452.GA24164@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jlee@suse.com, udknight@gmail.com,
	hayeswang@realtek.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56998 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423536Ab2LGRzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 12:55:48 -0500
In-Reply-To: <20121205223452.GA24164@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 5 Dec 2012 23:34:52 +0100

> GigaMAC registers have been reported left unitialized in several
> situations:
> - after cold boot from power-off state
> - after S3 resume
> 
> Tweaking rtl_hw_phy_config takes care of both.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/ethernet/realtek/r8169.c | 42 ++++++++++++++++++++----------------
>  1 file changed, 24 insertions(+), 18 deletions(-)
> 
>  YanQing and Chun-Yi, can you add your Signed-off-by to this patch ?
>  It contains bits of everybody's work but it does not match any. :o)
> 
>  I apparently play in the safe bios league since I did not notice any
>  difference before or after the patch.
> 
>  Beware, this patch seems to apply to net-next but doing so moves
>  rtl_rar_exgmac_set from rtl8168e_2_hw_phy_config to rtl8168f_hw_phy_config.
> 
>  Hayes, your comments are welcome if any.

Francois could you please respin this against net-next to avoid the unintended
consequence of applying the change to the wrong function?

If this change turns out to be more critical than it appears, and impact more
people than it appears, we can queue it up for -stable later.

Thanks.
