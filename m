From: Tino Keitel <tino.keitel@tikei.de>
Subject: strange sky disable/enable in the kernel log
Date: Fri, 22 Jun 2007 07:53:42 +0200
Message-ID: <20070622055342.GA11876@dose.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:48101 "EHLO
	eazy.amigager.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898AbXFVFxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 01:53:46 -0400
Received: from dose.home.local (port-212-202-201-164.dynamic.qsc.de [212.202.201.164])
	by eazy.amigager.de (Postfix) with ESMTP id 81D3E25C7EE
	for <netdev@vger.kernel.org>; Fri, 22 Jun 2007 07:53:44 +0200 (CEST)
Received: from scorpion by dose.home.local with local (Exim 4.67)
	(envelope-from <tino.keitel@tikei.de>)
	id 1I1c5W-00037e-IW
	for netdev@vger.kernel.org; Fri, 22 Jun 2007 07:53:42 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I just found this in the kernel log:

2007-06-22_05:47:50.69894 kern.info: sky2 eth0: disabling interface
2007-06-22_05:47:50.72039 kern.info: sky2 eth0: enabling interface
2007-06-22_05:47:50.72240 kern.info: sky2 eth0: ram buffer 48K
2007-06-22_05:47:52.40903 kern.info: sky2 eth0: Link is up at 100 Mbps,
full duplex, flow control both

What could be the cause for this? I use kernel 2.6.22-rc5 with this
hardware:

sky2 0000:01:00.0: v1.14 addr 0x90200000 irq 17 Yukon-EC (0xb6) rev 2

01:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053
PCI-E Gigabit Ethernet Controller (rev 22)

Regards,
Tino
