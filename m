From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: tg3 does not want to go up (config space problems).
Date: Mon, 14 May 2007 18:54:20 +0400
Message-ID: <20070514145419.GA19679@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:37718 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756717AbXENOyY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2007 10:54:24 -0400
Received: from 2ka.mipt.ru (localhost [127.0.0.1])
	by 2ka.mipt.ru (8.13.8/8.13.8) with ESMTP id l4EEsLT6010390
	for <netdev@vger.kernel.org>; Mon, 14 May 2007 18:54:22 +0400
Received: (from johnpol@localhost)
	by 2ka.mipt.ru (8.13.8/8.12.1/Submit) id l4EEsK5k010389
	for netdev@vger.kernel.org; Mon, 14 May 2007 18:54:20 +0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

I've cought a problem with my laptop and tg3 driver.
Suddenly (it was turned off quite for a while) tg3 driver does not start
up.

Here is dmesg messages (copied by hand, some bits are ommitted):
acpi: ... // device enbaled in couple of words

eth0: Tigon3 [partno(BMC5705mA3) rev 3003 PHY(5705)] pci:33/32, 10/100

eth0: rxcsum[1] linkchgreg[0] miirq[0] asf[0] split[0] wirespeed[0]
tsocap[1]
eth0: dma_rwctrl[763f0000] dma_mask[64 bit]

PM: writing back config space on device /* tg3 device pcix id*/ at
offset b (was 165d14e4, writing 890103c)
offset 3 (was 0, writing 4010)
offset 2 (was 2000000, writing 2000003)
offset 1 (was 2b00000, writing 2b00006)
offset 0 (was 165d14e4, writing 165e14e4)

ADDRCONF(NETDEV_UP): eth0 link is not ready

This problem never happend before, but suddenly appeared after quite
long suspend to disk (several month I think).
Nothing was changed in hardware.
Both 2.6.18 and 2.6.21-rc3 have the same issue.
No interrupts reported in /proc/interrupts.

I have 2.6.21-rc3 source tree in laptop, so can apply patches by hand
reading them from main desktop, but can not (easily) install additional 
software.

Thanks.

-- 
	Evgeniy Polyakov
