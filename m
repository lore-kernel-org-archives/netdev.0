From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 00/16 V2] Add new driver for RTL8723BE
Date: Fri, 28 Feb 2014 14:49:39 -0600
Message-ID: <5310F663.8070607@lwfinger.net>
References: <1393089433-28270-1-git-send-email-Larry.Finger@lwfinger.net> <20140228193241.GJ30876@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:55552 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbaB1Utm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 15:49:42 -0500
In-Reply-To: <20140228193241.GJ30876@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/2014 01:32 PM, John W. Linville wrote:
> With these patches applied, I get this build failure:
>
>    LD      drivers/net/wireless/rtlwifi/rtl8723com/built-in.o
>    LD      drivers/net/wireless/rtlwifi/built-in.o
> drivers/net/wireless/rtlwifi/rtl8723be/built-in.o: In function `rtl_hal_pwrseqcmdparsing':
> (.text+0x100a9): multiple definition of `rtl_hal_pwrseqcmdparsing'
> drivers/net/wireless/rtlwifi/rtl8723ae/built-in.o:(.text+0x159ad): first defined here
> drivers/net/wireless/rtlwifi/rtl8723be/built-in.o: In function `rtl92c_phy_ap_calibrate':
> (.text+0xfa0b): multiple definition of `rtl92c_phy_ap_calibrate'
> drivers/net/wireless/rtlwifi/rtl8192c/built-in.o:(.text+0x62df): first defined here
> make[2]: *** [drivers/net/wireless/rtlwifi/built-in.o] Error 1
> make[1]: *** [drivers/net/wireless/rtlwifi] Error 2
> make: *** [drivers/net/wireless/] Error 2

Oh shoot!

I thought I had the problems fixed. Let me pull a new copy of wireless-testing 
and fix the problem.

Larry
