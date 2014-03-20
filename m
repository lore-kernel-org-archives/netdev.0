From: folkert <folkert@vanheusden.com>
Subject: invisible network device
Date: Thu, 20 Mar 2014 16:43:10 +0100
Message-ID: <20140320154310.GJ18912@belle.intranet.vanheusden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from keetweej.vanheusden.com ([80.101.105.103]:31467 "EHLO
	keetweej.vanheusden.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbaCTPnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 11:43:12 -0400
Received: from belle.intranet.vanheusden.com (unknown [192.168.64.100])
	by keetweej.vanheusden.com (Postfix) with ESMTP id 0488715F85A
	for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 16:43:11 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a Terra Mobile 1512 laptop.
Only when an ethernet cable is plugged in during reset (NOT after
resume, e.g. re-opening the lid) then the ethernet device is listed in
the lspci output and usable. In all other cases it is not even listed or
detected. Also pluging it in later won't help.

When it is there, it shows in lspci:

03:00.2 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8101E/RTL8102E PCI Express Fast Ethernet controller (rev 06)
Subsystem: CLEVO/KAPOK Computer Device 2400
Flags: bus master, fast devsel, latency 0, IRQ 40
I/O ports at e000 [size=256]
Memory at f0004000 (64-bit, prefetchable) [size=4K]
Memory at f0000000 (64-bit, prefetchable) [size=16K]
Capabilities: [40] Power Management version 3
Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
Capabilities: [70] Express Endpoint, MSI 01
Capabilities: [b0] MSI-X: Enable- Count=4 Masked-
Capabilities: [d0] Vital Product Data
Capabilities: [100] Advanced Error Reporting
Capabilities: [160] Device Serial Number 01-00-00-00-36-4c-e0-00
Kernel driver in use: r8169

There are no new bios-updates on the terra website last time I checked.
I also did not see any "green"-related switches in there.

My question now is: any ideas how to solve this? Or tips where to ask
these kind of questions?


Folkert van Heusden

-- 
Always wondered what the latency of your webserver is? Or how much more
latency you get when you go through a proxy server/tor? The numbers
tell the tale and with HTTPing you know them!
                                     http://www.vanheusden.com/httping/
-----------------------------------------------------------------------
Phone: +31-6-41278122, PGP-key: 1F28D8AE, www.vanheusden.com
