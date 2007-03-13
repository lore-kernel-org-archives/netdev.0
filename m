From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] tc35815: Fix an usage of streaming DMA API.
Date: Tue, 13 Mar 2007 12:04:18 -0700
Message-ID: <20070313120418.554a3a43@freekitty>
References: <20070303.235459.25478204.anemo@mba.ocn.ne.jp>
	<20070314.010220.65192616.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
	netdev@vger.kernel.org, jeff@garzik.org, sshtylyov@ru.mvista.com,
	akpm@linux-foundation.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:58711 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933030AbXCMTHx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 15:07:53 -0400
In-Reply-To: <20070314.010220.65192616.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Mar 2007 01:02:20 +0900 (JST)
Atsushi Nemoto <anemo@mba.ocn.ne.jp> wrote:

> The tc35815 driver lacks a call to pci_dma_sync_single_for_device() on
> receiving.  Recent fix of MIPS dma_sync_single_for_cpu() reveal this
> bug.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> ---
> This patch can be applied to netdev-2.6 tree or 2.6.21-rc3-mm2.
> 
> diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
> index ec888db..eed78b5 100644
> --- a/drivers/net/tc35815.c
> +++ b/drivers/net/tc35815.c
> @@ -58,12 +58,13 @@
>   *	1.34	Fix netpoll locking.  "BH rule" for NAPI is not enough with
>   *		netpoll, hard_start_xmit might be called from irq context.
>   *		PM support.
> + *	1.35	Fix an usage of streaming DMA API.
>   */

Please don't use comments as changelog anymore. It gets out of date.
The use of change control systems has made this practice obsolete.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
