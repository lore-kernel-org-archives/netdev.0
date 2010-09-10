From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] ipheth: remove incorrect devtype to WWAN
Date: Thu, 09 Sep 2010 21:42:21 -0700 (PDT)
Message-ID: <20100909.214221.241458705.davem@davemloft.net>
References: <1283968247.2839.14.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, diego-KR0zwsgql1HQT0dZR+AlfA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1283968247.2839.14.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Wed, 08 Sep 2010 12:50:47 -0500

> The 'wwan' devtype is meant for devices that require preconfiguration
> and *every* time setup before the ethernet interface can be used, like
> cellular modems which require a series of setup commands on serial ports
> or other mechanisms before the ethernet interface will handle packets.
> 
> As ipheth only requires one-per-hotplug pairing setup with no
> preconfiguration (like APN, phone #, etc) and the network interface is
> usable at any time after that initial setup, remove the incorrect
> devtype wwan.
> 
> Signed-off-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Applied, thanks Dan.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
