From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next v3 1/2] r8152:addRTL8152_EARLY_AGG_TIMEOUT_SUPER
Date: Sat, 15 Mar 2014 00:42:33 +0100
Message-ID: <20140314234233.GA2341@electric-eye.fr.zoreil.com>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6DCB6E@AcuExch.aculab.com>
 <20140313.132222.536931544768069240.davem@davemloft.net>
 <A56A13416A724183888BB62CEFD2B817@realtek.com.tw>
 <20140314.000741.1829674011496195593.davem@davemloft.net>
 <CE95F5CF3B924F0A921DDC3493A67365@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'David Miller'" <davem@davemloft.net>, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CE95F5CF3B924F0A921DDC3493A67365@realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hayeswang <hayeswang@realtek.com> :
[...]
> Besides, I don't wish to modify the setting by ethtool when re-loading
> the driver or rebooting every time.

Why ?

The recipe is different but there isn't much setup difference between a
module param and an ethtool command that is run through udev. The latter
is more versatile though.

> Excuse me. Why is it not accepted for being a Kconfig parameter.

You have stated that the optimal value is not easy to figure.

It's thus hard to give much credit to an hardcoded solution.

-- 
Ueimor
