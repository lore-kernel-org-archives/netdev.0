From: hayeswang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH net-next v3 1/2] r8152:addRTL8152_EARLY_AGG_TIMEOUT_SUPER
Date: Fri, 14 Mar 2014 15:24:50 +0800
Message-ID: <CE95F5CF3B924F0A921DDC3493A67365@realtek.com.tw>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6DCB6E@AcuExch.aculab.com><20140313.132222.536931544768069240.davem@davemloft.net><A56A13416A724183888BB62CEFD2B817@realtek.com.tw> <20140314.000741.1829674011496195593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: 'David Miller' <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140314.000741.1829674011496195593.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 From: David Miller [mailto:davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org] 
 Sent: Friday, March 14, 2014 12:08 PM
[...]
> >> And I fundamentally disagree with this being a Kconfig parameter.
> >> 
> >> Make it run-time calculated _or_ settable via ethtool.
> > 
> > Excuse me. How should I make it run-time calculated without a
> > Kconfig parameter? Should I use module_param? 
> 
> You run-time determine the setting based upon the negotiated link
> speed and traffic patterns.

It is difficult to design a algorithm which considers the hardware
of the platform, network traffic, and even the USB behavior to
dynamically modify the setting. I don't think I have the capability
to do it.

Besides, I don't wish to modify the setting by ethtool when re-loading
the driver or rebooting every time.

Excuse me. Why is it not accepted for being a Kconfig parameter.
It let the manufactuers of some platforms, especially the embedded
system, could tune their performance. Should I give up this patch?

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
