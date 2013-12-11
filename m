From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/1] AX88179_178A: Enable the hardware pseudo header in
 case of the NET_IP_ALIGN equals 0
Date: Wed, 11 Dec 2013 12:16:12 -0500 (EST)
Message-ID: <20131211.121612.1818249304919726954.davem@davemloft.net>
References: <1386323898-2246-1-git-send-email-freddy@asix.com.tw>
	<20131209.200131.1376169274733452706.davem@davemloft.net>
	<52A80397.2080508@asix.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, louis-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org, allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org
To: freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52A80397.2080508-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Date: Wed, 11 Dec 2013 14:17:59 +0800

> I think there is no way of undoing the reservation in the driver.

Then you should add a flag that, indeed, tells usbnet not to do the
reservation in the first place.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
