From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 0/3] r8152: configuration setting
Date: Wed, 07 Sep 2016 17:37:46 -0700 (PDT)
Message-ID: <20160907.173746.787161029125318872.davem@davemloft.net>
References: <1394712342-15778-215-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-215-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Date: Wed, 7 Sep 2016 16:12:19 +0800

> Some people prefer to use ECM mode rather than vendor mode. Therefore, I add
> CONFIG_RTL8152_CONFIG_VALUE in Kconfig. Then, the users could choose the USB
> configuration value which they want. The default is to support vendor mode
> only.

By forcing a certain mode via a Kconfig value, you are basically making it
impossible for distributions to do something reasonable here.

This needs to be somehow a runtime thing, and I'm pretty sure we've
had many other situations of USB devices which want to be run by
different "personality" drivers in the past.

Perhaps we can do something generically for USB devices for this kind
of situation and make r8152 use it.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
