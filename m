From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: irda-usb: use msecs_to_jiffies for conversions
Date: Mon, 25 May 2015 17:39:46 -0400 (EDT)
Message-ID: <20150525.173946.265552397243249712.davem@davemloft.net>
References: <1432385190-6333-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hofrat@osadl.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432385190-6333-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Mc Guire <hofrat@osadl.org>
Date: Sat, 23 May 2015 14:46:30 +0200

> API compliance scanning with coccinelle flagged:
> 
> Converting milliseconds to jiffies by "val * HZ / 1000" is technically
> is not a clean solution as it does not handle all corner cases correctly.
> By changing the conversion to use msecs_to_jiffies(val) conversion is
> correct in all cases.
> 
> in the current code: 
>   mod_timer(&self->rx_defer_timer, jiffies + (10 * HZ / 1000));
> for HZ < 100 (e.g. CONFIG_HZ == 64|32 in alpha) this effectively results 
> in no delay at all.
> 
> Patch was compile tested for x86_64_defconfig (implies CONFIG_USB_IRDA=m)
> 
> Patch is against 4.1-rc4 (localversion-next is -next-20150522)
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Applied to net-next, thanks.
