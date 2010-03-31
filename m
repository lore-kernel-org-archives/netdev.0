From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: re-submit2 [ANNOUNCEMENT] NET: usb: sierra_net.c driver
Date: Tue, 30 Mar 2010 23:10:51 -0700 (PDT)
Message-ID: <20100330.231051.113008279.davem@davemloft.net>
References: <1269893596.9242.7.camel@Linuxdev3>
	<20100330.230932.244208287.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100330.230932.244208287.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Date: Tue, 30 Mar 2010 23:09:32 -0700 (PDT)

> From: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
> Date: Mon, 29 Mar 2010 13:13:16 -0700
> 
>> Subject: re-submit2 [ANNOUNCEMENT] NET: usb: sierra_net.c driver
>> From: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
> 
> Applied, thanks.

Nevermind, reverted, it doesn't even build.

drivers/net/usb/sierra_net.c: In function 'check_ethip_packet':
drivers/net/usb/sierra_net.c:221:3: error: implicit declaration of function 'deverr'

Really, this should never ever happen, and there is simply
no excuse at all for this.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
