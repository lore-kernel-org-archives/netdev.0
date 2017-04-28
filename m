From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: hso: register netdev later to avoid a race
 condition
Date: Fri, 28 Apr 2017 16:12:15 -0400 (EDT)
Message-ID: <20170428.161215.1554269734409048791.davem@davemloft.net>
References: <1493227600-10102-1-git-send-email-andreas@kemnade.info>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
        peter-WaGBZJeGNqdsbIuE7sb01tBPR1lH4CV8@public.gmane.org, hns-xXXSsgcRVICgSpxsJD1C4w@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: andreas-cLv4Z9ELZ06ZuzBka8ofvg@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1493227600-10102-1-git-send-email-andreas-cLv4Z9ELZ06ZuzBka8ofvg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andreas Kemnade <andreas-cLv4Z9ELZ06ZuzBka8ofvg@public.gmane.org>
Date: Wed, 26 Apr 2017 19:26:40 +0200

> If the netdev is accessed before the urbs are initialized,
> there will be NULL pointer dereferences. That is avoided by
> registering it when it is fully initialized.
> 
> This case occurs e.g. if dhcpcd is running in the background
> and the device is probed, either after insmod hso or
> when the device appears on the usb bus.
> 
> A backtrace is the following:
 ...
> Reported-by: H. Nikolaus Schaller <hns-xXXSsgcRVICgSpxsJD1C4w@public.gmane.org>
> Signed-off-by: Andreas Kemnade <andreas-cLv4Z9ELZ06ZuzBka8ofvg@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
