From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Fried r8169.
Date: Thu, 25 Oct 2007 23:36:45 +0200
Message-ID: <20071025213645.GA2226@electric-eye.fr.zoreil.com>
References: <20071025154438.GA2673@hermes.priv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: Tom Prince <tom.prince@ualberta.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:35610 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752650AbXJYVmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 17:42:33 -0400
Content-Disposition: inline
In-Reply-To: <20071025154438.GA2673@hermes.priv>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tom Prince <tom.prince@ualberta.net> :
> While testing Linux v2.6.24-rc1, I noticed that my onboard r8169 had
> disappeared, and the it remained gone when I rebooted to v2.6.23 and v2.6.22,
> where it had previously worked.

[...]
> I am running x86_64 ASUS Z92T laptop (an OEM version of the A6T).
> 
> I have posted dmesg/lspci/config from v2.6.23 (and soon v2.6.24) at 
>  www.math.uwo.ca/~rprince5/r8169/
> 
> Also these appear to be the relevant log messages from when the device was
> working. Unfortunately, I didn't have the foresight to save dmesg/lspci from
> before the device disappeared.

Can you try an older/vendor kernel and power-off the host before restarting ?

I have experienced something similar. My 8168b returns but the magic spell
is still not clear.

[...]
> kernel: r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
> kernel: ACPI: PCI Interrupt Link [LNEA] enabled at IRQ 16
> kernel: ACPI: PCI Interrupt 0000:01:00.0[A] -> Link [LNEA] -> GSI 16 (level, low) -> IRQ 16
> kernel: PCI: Setting latency timer of device 0000:01:00.0 to 64
> kernel: eth1: RTL8168b/8111b at 0xffffc200020e2000, 00:18:f3:87:0b:bb, XID 38000000 IRQ 16

8168b as well. Okay...

-- 
Ueimor
