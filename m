From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: r8169 MAC addresses broken
Date: Sun, 26 Oct 2008 13:52:21 +0100
Message-ID: <m33aijzfga.fsf@maximus.localdomain>
References: <490380C8.6070003@simon.arlott.org.uk>
	<4903947A.3060206@gmail.com>
	<20081025223443.GA30913@electric-eye.fr.zoreil.com>
	<490448B0.8050307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Ivan Vecera <ivecera@redhat.com>
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:44410 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753213AbYJZMwX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Oct 2008 08:52:23 -0400
In-Reply-To: <490448B0.8050307@gmail.com> (Jiri Slaby's message of "Sun\, 26 Oct 2008 11\:38\:40 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Slaby <jirislaby@gmail.com> writes:

> However I may have a hw failure or some bug overwrote my eeprom, I see this
> in current mmotm:
> r8169 0000:06:00.0: PCI INT A disabled
> r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> r8169 0000:06:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
> r8169 0000:06:00.0: setting latency timer to 64
> r8169: mac_version = 0x0c
> r8169 0000:06:00.0: irq 43 for MSI/MSI-X
> r8169: MAC address found in EEPROM: 00:00:00:00:00:00
> eth0: RTL8168b/8111b at 0xffffc200042b0000, 00:00:00:00:00:00, XID 38000000

I think we need drivers or maybe some tool to save contents of those
little EEPROM / flash NVM configuration chips before it's too late.
First the ICH* e1000e corruption and now GbE RTL.
-- 
Krzysztof Halasa
