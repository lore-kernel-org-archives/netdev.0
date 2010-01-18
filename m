From: Andreas Sundstrom <sunkan@zappa.cx>
Subject: Re: ~60k interrupts/sec for 1Gb/s iperf with r8169
Date: Mon, 18 Jan 2010 15:43:09 +0100
Message-ID: <4B54737D.20306@zappa.cx>
References: <4B5447E3.5090405@zappa.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alva.zappa.cx ([213.88.132.89]:35542 "EHLO alva.zappa.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753122Ab0AROnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jan 2010 09:43:13 -0500
Received: from matrix.zappa.cx ([2001:16d8:ff9b:2:211:9ff:fe8a:f658])
	by alva.zappa.cx with esmtp (Exim 4.69)
	(envelope-from <sunkan@zappa.cx>)
	id 1NWsox-0006hR-U7
	for netdev@vger.kernel.org; Mon, 18 Jan 2010 15:43:12 +0100
Received: from [10.8.0.6] (openvpn6.zappa.cx [10.8.0.6] (may be forged))
	(authenticated bits=0)
	by matrix.zappa.cx (8.14.3/8.14.3/Debian-5) with ESMTP id o0IEhA1B026414
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 15:43:12 +0100
In-Reply-To: <4B5447E3.5090405@zappa.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andreas Sundstrom wrote:
> Here is the relevant dmesg output for my NIC. It's an integrated
> NIC on my ASUS M2A-VM HDMI mb.
> 
> r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> r8169 0000:02:00.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
> r8169 0000:02:00.0: setting latency timer to 64
> r8169 0000:02:00.0: irq 26 for MSI/MSI-X
> eth0: RTL8168b/8111b at 0xffffc90010944000, 00:1f:c6:b3:ff:eb, XID 18000000 IRQ 26
> r8169: eth0: chipset (mac_version = 12).
> 
> I added the output of the mac_version when I was troubleshooting.

I realized that I didn't say what kernel I was using.
But this was all with plain 2.6.32.3 kernel

/Andreas Sundstrom
