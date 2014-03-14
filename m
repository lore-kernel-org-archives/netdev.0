From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/2] r8152:
 addRTL8152_EARLY_AGG_TIMEOUT_SUPER
Date: Fri, 14 Mar 2014 00:07:41 -0400 (EDT)
Message-ID: <20140314.000741.1829674011496195593.davem@davemloft.net>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6DCB6E@AcuExch.aculab.com>
	<20140313.132222.536931544768069240.davem@davemloft.net>
	<A56A13416A724183888BB62CEFD2B817@realtek.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, netdev@vger.kernel.org,
	nic_swsd@realtek.com, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <A56A13416A724183888BB62CEFD2B817@realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: hayeswang <hayeswang@realtek.com>
Date: Fri, 14 Mar 2014 10:37:21 +0800

>  From: David Miller [mailto:davem@davemloft.net] 
>  Sent: Friday, March 14, 2014 1:22 AM
> [...]
>> And I fundamentally disagree with this being a Kconfig parameter.
>> 
>> Make it run-time calculated _or_ settable via ethtool.
> 
> Excuse me. How should I make it run-time calculated without a
> Kconfig parameter? Should I use module_param? 

You run-time determine the setting based upon the negotiated link
speed and traffic patterns.
