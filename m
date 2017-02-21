From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] Revert "ath10k: Search SMBIOS for OEM board file
 extension"
Date: Tue, 21 Feb 2017 16:00:07 -0500 (EST)
Message-ID: <20170221.160007.633338603929529207.davem@davemloft.net>
References: <1487706426-31172-1-git-send-email-kvalo@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1487706426-31172-1-git-send-email-kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Date: Tue, 21 Feb 2017 21:47:06 +0200

> This reverts commit f2593cb1b29185d38db706cbcbe22ed538720ae1.
> 
> Paul reported that this patch with older board-2.bin ath10k initialisation
> fails on Dell XPS 13:
> 
> ath10k_pci 0000:3a:00.0: failed to fetch board data for bus=pci,vendor=168c,
> device=003e,subsystem-vendor=1a56,subsystem-device=1535,variant=RV_0520 from
> ath10k/QCA6174/hw3.0/board-2.bin
> 
> The reason is that the older board-2.bin does not have the variant version of
> the image name and ath10k does not fallback to the older naming scheme.
> 
> Reported-by: Paul Menzel <pmenzel-KUpvgZVWgV9o1qOY/usvUg@public.gmane.org>
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=185621#c9
> Fixes: f2593cb1b291 ("ath10k: Search SMBIOS for OEM board file extension")
> Signed-off-by: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
> ---
> 
> Dave, please take this directly if you can.

Applied, thanks Kalle.
