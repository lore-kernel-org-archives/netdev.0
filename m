From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 4/6] ath6kl: get rid of AR_DBG_LVL_CHECK()
Date: Wed, 04 Jan 2012 15:58:35 -0800
Message-ID: <1325721515.4116.11.camel@joe2Laptop>
References: <20120104230429.32306.75965.stgit@x201>
	 <20120104230921.32306.63985.stgit@x201>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org,
	ath6kl-devel@qualcomm.com, davem@davemloft.net
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120104230921.32306.63985.stgit@x201>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-01-05 at 01:09 +0200, Kalle Valo wrote:
> We don't need it as debug calls already have a log level and compiler
> should be smart enough to optimise away the code when ath6kl debug code
> is not enabled. Also it makes it easier to abstract core code to
> ath6kl_core.ko.

Changelog isn't representative of code changes.
ATH6KL_DBG_ANY -> ATH6KL_DBG_IRQ.

> diff --git a/drivers/net/wireless/ath/ath6kl/debug.c b/drivers/net/wireless/ath/ath6kl/debug.c
[]
> @@ -82,31 +82,31 @@ void ath6kl_dump_registers(struct ath6kl_device *dev,
>  			   struct ath6kl_irq_enable_reg *irq_enable_reg)
>  {
>  
> -	ath6kl_dbg(ATH6KL_DBG_ANY, ("<------- Register Table -------->\n"));
> +	ath6kl_dbg(ATH6KL_DBG_IRQ, ("<------- Register Table -------->\n"));

etc...
