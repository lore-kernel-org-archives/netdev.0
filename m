From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: r8169 MAC addresses broken
Date: Sun, 26 Oct 2008 11:38:40 +0100
Message-ID: <490448B0.8050307@gmail.com>
References: <490380C8.6070003@simon.arlott.org.uk> <4903947A.3060206@gmail.com> <20081025223443.GA30913@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Ivan Vecera <ivecera@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:37556 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056AbYJZKio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 06:38:44 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1548834fgg.17
        for <netdev@vger.kernel.org>; Sun, 26 Oct 2008 03:38:42 -0700 (PDT)
In-Reply-To: <20081025223443.GA30913@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu napsal(a):
> Jiri Slaby <jirislaby@gmail.com> :
> [...]
>> Ah, I thought I have broken hardware. I have similar problem, my mac is
>> initially all zeroes. When I set it up, it works until suspend. After that I
>> need to unbind the driver, bind it again, and it works then (mac is still the
>> set one).
>>
>> I'm out of the notebook right now, but it is 10ec:8168:
>> 06:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI
>> Express Gigabit Ethernet controller (rev 01)
>> 	Subsystem: ASUSTeK Computer Inc. Unknown device 11f5
>>
>> I used it perfectly far later than 2.6.24 (maybe 2.6.26?), 2.6.27 is yet
>> defunct.
> 
> 2.6.27 proper ? That's bad news.
> 
> Can you send a dmesg for 2.6.27 and 2.6.28-rc1 ?

2.6.28-rc1 doesn't boot, the rest of dmesgs is at:
http://decibel.fi.muni.cz/~xslaby/r8169_mac/

However I may have a hw failure or some bug overwrote my eeprom, I see this
in current mmotm:
r8169 0000:06:00.0: PCI INT A disabled
r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:06:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
r8169 0000:06:00.0: setting latency timer to 64
r8169: mac_version = 0x0c
r8169 0000:06:00.0: irq 43 for MSI/MSI-X
r8169: MAC address found in EEPROM: 00:00:00:00:00:00
eth0: RTL8168b/8111b at 0xffffc200042b0000, 00:00:00:00:00:00, XID 38000000
IRQ 43
r8169: mac_version = 0x0c

which looks like even in the eeprom are all zeroes now. Also 2.6.25 is
affected by this now and it worked (from_Jul dmesg).
