From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2010-12-15
Date: Wed, 15 Dec 2010 09:54:14 -0800 (PST)
Message-ID: <20101215.095414.193705657.davem@davemloft.net>
References: <20101215155642.GE2377@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20101215155642.GE2377-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Wed, 15 Dec 2010 10:56:42 -0500

> This is a batch of fixes intended for 2.6.37.
> 
> The biggest changes fix an issue where the iwlagn driver will misread
> the EEPROM information for some devices that will soon be in the wild.
> The initial impulse was to rewrite the EEPROM code, but I pushed back on
> that for 2.6.37.  The compromise is to add the new EEPROM reading code,
> but only to invoke it for the new devices.  Older devices will still use
> the existing (and tested) EEPROM code.  Note that all devices will use
> the new code in 2.6.38 and beyond.
> 
> This also includes a pull of bluetooth fixes from Gustavo Padovan.  That
> includes a null pointer fix and a fix for a regression that broke the
> DUN profile -- say goodbye to your emergency cell-phone Internet
> connection without that!
> 
> Other patches include some device ID additions for p54usb, a fix to
> avoid log spam resulting from suspend/resume with USB-based wireless
> devices that don't define their own suspend hook, a null ptr fix for the
> libertas driver, and another null pointer fix related to IBSS merges.
> 
> Please let me know if there are problems!

Looks good, pulled, thanks John.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
