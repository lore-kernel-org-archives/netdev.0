From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/2]
 r8152:addRTL8152_EARLY_AGG_TIMEOUT_SUPER
Date: Fri, 14 Mar 2014 14:43:11 -0400 (EDT)
Message-ID: <20140314.144311.2001561184461945910.davem@davemloft.net>
References: <A56A13416A724183888BB62CEFD2B817@realtek.com.tw>
	<20140314.000741.1829674011496195593.davem@davemloft.net>
	<CE95F5CF3B924F0A921DDC3493A67365@realtek.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, netdev@vger.kernel.org,
	nic_swsd@realtek.com, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CE95F5CF3B924F0A921DDC3493A67365@realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: hayeswang <hayeswang@realtek.com>
Date: Fri, 14 Mar 2014 15:24:50 +0800

> Besides, I don't wish to modify the setting by ethtool when re-loading
> the driver or rebooting every time.

You have code to reset the driver, you can do it when the user asks
for the setting to be changed via ethtool.  I do not see this as
a problem.

The ethtool change can occur while the driver is already up, you'll
just need to reset the chip and make the new configuration, this is
not a problem.

> Excuse me. Why is it not accepted for being a Kconfig parameter.
> It let the manufactuers of some platforms, especially the embedded
> system, could tune their performance. Should I give up this patch?

We want to discourage such hard-coding, not encourage it.

I think you are limiting yourself unnecessarily by refusing to
consider that there may be ways other than Kconfig to adjust this
setting.
