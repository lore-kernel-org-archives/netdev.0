From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 5/6] hso: Fix for 5 sec timeouts with v2.x firmware
Date: Thu, 07 Jan 2010 00:44:29 -0800 (PST)
Message-ID: <20100107.004429.24094839.davem@davemloft.net>
References: <20100105145242.GE19825@raptor>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100105145242.GE19825@raptor>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Date: Tue, 5 Jan 2010 15:52:42 +0100

> From: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
> 
> Don't send flow control settings to any port other than the modem port.
> Older firmware ignored this request but did sent a reply. Newer firmware just
> ignores it without reply and causes a 5 second timeout every time a port
> (except for the modem port) is opened or if tiocm settings are changed.
> 
> Signed-off-by: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
