From: Borislav Petkov <bp@alien8.de>
Subject: e1000e 0000:00:19.0 eth0: Hardware Error
Date: Thu, 10 Apr 2014 13:59:41 +0200
Message-ID: <20140410115941.GI29093@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
To: e1000-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi guys,

I started getting those sporadic

[133178.640890] e1000e 0000:00:19.0 eth0: Hardware Error
[133179.293148] e1000e 0000:00:19.0: irq 45 for MSI/MSI-X
[133179.394226] e1000e 0000:00:19.0: irq 45 for MSI/MSI-X
[133179.397200] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[133181.338258] e1000e 0000:00:19.0 eth0: Hardware Error
[133182.077209] pci_pm_runtime_suspend(): e1000_runtime_suspend+0x0/0x40 [e1000e] returns -2

messages with 3.14 and I haven't had them before. After this, I do

rmmod e1000e && modprobe e1000e

and I get:

[133221.891555] e1000e 0000:00:19.0 eth0: removed PHC
[133228.181552] e1000e: Intel(R) PRO/1000 Network Driver - 2.3.2-k
[133228.181562] e1000e: Copyright(c) 1999 - 2013 Intel Corporation.
[133228.182241] e1000e 0000:00:19.0: Interrupt Throttling Rate (ints/sec) set to dynamic conservative mode
[133228.182332] e1000e 0000:00:19.0: irq 45 for MSI/MSI-X
[133229.009837] e1000e: probe of 0000:00:19.0 failed with error -2
			^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

[133307.107217] e1000e: Intel(R) PRO/1000 Network Driver - 2.3.2-k
[133307.107228] e1000e: Copyright(c) 1999 - 2013 Intel Corporation.
[133307.107814] e1000e 0000:00:19.0: Interrupt Throttling Rate (ints/sec) set to dynamic conservative mode
[133307.107959] e1000e 0000:00:19.0: irq 45 for MSI/MSI-X
[133307.935921] e1000e: probe of 0000:00:19.0 failed with error -2

...

[133841.361905] e1000e: Intel(R) PRO/1000 Network Driver - 2.3.2-k
[133841.361914] e1000e: Copyright(c) 1999 - 2013 Intel Corporation.
[133841.362451] e1000e 0000:00:19.0: Interrupt Throttling Rate (ints/sec) set to dynamic conservative mode
[133841.362520] e1000e 0000:00:19.0: irq 45 for MSI/MSI-X
[133842.192710] e1000e: probe of 0000:00:19.0 failed with error -2

each time I try and eth0 is dead. Only a reboot helps, I've come to find
out so far.

Any ideas?

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
