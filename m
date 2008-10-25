From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 MAC addresses broken
Date: Sun, 26 Oct 2008 00:34:43 +0200
Message-ID: <20081025223443.GA30913@electric-eye.fr.zoreil.com>
References: <490380C8.6070003@simon.arlott.org.uk> <4903947A.3060206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Ivan Vecera <ivecera@redhat.com>
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46669 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751586AbYJYWfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2008 18:35:13 -0400
Content-Disposition: inline
In-Reply-To: <4903947A.3060206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Slaby <jirislaby@gmail.com> :
[...]
> Ah, I thought I have broken hardware. I have similar problem, my mac is
> initially all zeroes. When I set it up, it works until suspend. After that I
> need to unbind the driver, bind it again, and it works then (mac is still the
> set one).
> 
> I'm out of the notebook right now, but it is 10ec:8168:
> 06:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI
> Express Gigabit Ethernet controller (rev 01)
> 	Subsystem: ASUSTeK Computer Inc. Unknown device 11f5
> 
> I used it perfectly far later than 2.6.24 (maybe 2.6.26?), 2.6.27 is yet
> defunct.

2.6.27 proper ? That's bad news.

Can you send a dmesg for 2.6.27 and 2.6.28-rc1 ?

> This should be perfectly bisectable, would you, Simon? If this is not
> fixed already -- I don't think so, mmotm few days ago is still broken.
> Francois, anybody, does this ring bells anywhere?

It may go away if one comments out rtl_init_mac_address in rtl8169_init_one
but I'd really like to figure why the driver loses the first 32 bits of the
mac address while it is perfectly able to read it correctly from the eeprom.

-- 
Ueimor
