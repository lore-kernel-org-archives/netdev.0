From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: r8169 MAC addresses broken
Date: Tue, 04 Nov 2008 22:10:25 +0100
Message-ID: <4910BA41.5020709@gmail.com>
References: <490380C8.6070003@simon.arlott.org.uk>	<4903947A.3060206@gmail.com>	<20081025223443.GA30913@electric-eye.fr.zoreil.com>	<4904A7C5.7090801@gmail.com>	<20081026174654.GB24790@electric-eye.fr.zoreil.com>	<4906E4BE.9050304@gmail.com> <m3mygozvd4.fsf@maximus.localdomain> <490718C7.3010501@gmail.com> <490EBE83.7030309@redhat.com> <490F0FCF.4060905@gmail.com> <49109946.7020702@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Halasa <khc@pm.waw.pl>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Arjan van de Ven <arjan@infradead.org>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:21516 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752928AbYKDVK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 16:10:26 -0500
In-Reply-To: <49109946.7020702@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ivan Vecera napsal(a):
> Francois has fix for this problem (zeroed MAC address) in his repository:
> http://git.kernel.org/?p=linux/kernel/git/romieu/netdev-2.6.git;a=commitdiff;h=9b1abbccf53ef1a1213b159d56257b535c599f07

I've applied the 2 patches with this result:
r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:06:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
r8169 0000:06:00.0: setting latency timer to 64
r8169 0000:06:00.0: irq 43 for MSI/MSI-X
r8169 0000:06:00.0: Missing EEPROM signature: 00000000
eth0: RTL8168b/8111b at 0xffffc20000038000, 00:18:f3:f8:e1:ca, XID 38000000
IRQ 43
