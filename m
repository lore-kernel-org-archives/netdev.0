From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 5/6] ath6kl: convert ath6kl_dbg() and
 ath6kl_dbg_dump() into functions
Date: Thu, 05 Jan 2012 08:38:09 -0800
Message-ID: <1325781489.22154.19.camel@joe2Laptop>
References: <20120105132523.22281.95999.stgit@x201>
	 <20120105132834.22281.78822.stgit@x201>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org,
	ath6kl-devel@qualcomm.com, davem@davemloft.net
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120105132834.22281.78822.stgit@x201>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-01-05 at 15:28 +0200, Kalle Valo wrote:

Hey Kalle.

> diff --git a/drivers/net/wireless/ath/ath6kl/debug.c b/drivers/net/wireless/ath/ath6kl/debug.c
[]
> +void ath6kl_dbg(enum ATH6K_DEBUG_MASK mask, const char *fmt, ...)
[]
> +	ath6kl_printk(KERN_DEBUG, "%pV", &vaf);
[
> diff --git a/drivers/net/wireless/ath/ath6kl/debug.h b/drivers/net/wireless/ath/ath6kl/debug.h
[]
> +void ath6kl_dbg(enum ATH6K_DEBUG_MASK mask, const char *fmt, ...);

You need to add

__printf(2, 3)

to the prototype.

If it's not there, the printf formats and arguments aren't verified.
%pV could do the wrong/bad things.
