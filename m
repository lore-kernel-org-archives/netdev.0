From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: r8169 MAC addresses broken
Date: Tue, 28 Oct 2008 10:12:51 +0100
Message-ID: <4906D793.8020109@redhat.com>
References: <490380C8.6070003@simon.arlott.org.uk>	<4903947A.3060206@gmail.com>	<20081025223443.GA30913@electric-eye.fr.zoreil.com>	<490448B0.8050307@gmail.com> <m33aijzfga.fsf@maximus.localdomain> <49061B7E.6050409@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Halasa <khc@pm.waw.pl>, Jiri Slaby <jirislaby@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46592 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751372AbYJ1OXm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2008 10:23:42 -0400
In-Reply-To: <49061B7E.6050409@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Arlott napsal(a):
> On 26/10/08 12:52, Krzysztof Halasa wrote:
>> Jiri Slaby <jirislaby@gmail.com> writes:
>>
>>> However I may have a hw failure or some bug overwrote my eeprom, I see this
>>> in current mmotm:
>>> r8169 0000:06:00.0: PCI INT A disabled
>>> r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
>>> r8169 0000:06:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
>>> r8169 0000:06:00.0: setting latency timer to 64
>>> r8169: mac_version = 0x0c
>>> r8169 0000:06:00.0: irq 43 for MSI/MSI-X
>>> r8169: MAC address found in EEPROM: 00:00:00:00:00:00
>>> eth0: RTL8168b/8111b at 0xffffc200042b0000, 00:00:00:00:00:00, XID 38000000
>> I think we need drivers or maybe some tool to save contents of those
>> little EEPROM / flash NVM configuration chips before it's too late.
>> First the ICH* e1000e corruption and now GbE RTL.
> 
> With the reverted patch my MAC addresses are still broken:
Try full power-off (disconnect power supply/remove battery).

> 
> [    1.527660] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> [    1.533421] r8169 0000:00:09.0: PCI INT A -> Link[LNKC] -> GSI 10 (level, low) -> IRQ 10
> [    1.541743] r8169 0000:00:09.0: PCI: Disallowing DAC for device
> [    1.547799] r8169 0000:00:09.0: no PCI Express capability
> [    1.554519] eth0: RTL8169sc/8110sc at 0xbf6f8000, 00:00:00:00:25:c2, XID 18000000 IRQ 10
> 
> [    1.563480] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> [    1.570525] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
> [    1.576363] r8169 0000:00:0b.0: PCI INT A -> Link[LNKD] -> GSI 11 (level, low) -> IRQ 11
> [    1.584597] r8169 0000:00:0b.0: PCI: Disallowing DAC for device
> [    1.590651] r8169 0000:00:0b.0: no PCI Express capability
> [    1.596659] eth1: RTL8169sc/8110sc at 0xbf6fc000, 00:00:00:00:25:c3, XID 18000000 IRQ 11
> 

