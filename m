From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: wl18xx: show rx_frames_per_rates as an array as it really is
Date: Mon, 16 Mar 2015 16:07:33 +0000 (UTC)
Message-ID: <20150316160734.00F6113FC52@smtp.codeaurora.org>
References: <1426231034-20163-1-git-send-email-nicolas.iooss_linux@m4x.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eliad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Nicolas Iooss <nicolas.iooss_linux-oWGTIYur0i8@public.gmane.org>
To: Nicolas Iooss <nicolas.iooss_linux-oWGTIYur0i8@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1426231034-20163-1-git-send-email-nicolas.iooss_linux-oWGTIYur0i8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> In struct wl18xx_acx_rx_rate_stat, rx_frames_per_rates field is an
> array, not a number.  This means WL18XX_DEBUGFS_FWSTATS_FILE can't be
> used to display this field in debugfs (it would display a pointer, not
> the actual data).  Use WL18XX_DEBUGFS_FWSTATS_FILE_ARRAY instead.
> 
> This bug has been found by adding a __printf attribute to
> wl1271_format_buffer.  gcc complained about "format '%u' expects
> argument of type 'unsigned int', but argument 5 has type 'u32 *'".
> 
> Fixes: c5d94169e818 ("wl18xx: use new fw stats structures")
> Signed-off-by: Nicolas Iooss <nicolas.iooss_linux-oWGTIYur0i8@public.gmane.org>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
