From: "Stefan Bottelier | Ocius.nl" <stefan@ocius.nl>
Subject: Problem with 10Gbit Broadcom NetXtreme II 5771x/578xx 10/20-Gigabit
 Ethernet Driver
Date: Fri, 24 Oct 2014 10:42:52 +0200
Message-ID: <544A110C.4030402@ocius.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Axlion.ocius.nl ([178.18.143.21]:39565 "EHLO Axlion.ocius.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750909AbaJXJAm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2014 05:00:42 -0400
Received: from [94.103.146.186] (helo=MacBook-Pro-Retina-van-Stefan.local)
	by Axlion.ocius.nl with esmtpsa (TLSv1:DHE-RSA-AES128-SHA:128)
	(Exim 4.83)
	(envelope-from <stefan@ocius.nl>)
	id 1XhaGU-000L1y-OR
	for netdev@vger.kernel.org; Fri, 24 Oct 2014 10:30:30 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

We are using Dell Blade Centers, but we get a error on the 10Gbit 
Broadcom adapter bnx2x

bnx2x 0000:01:00.0: part number 394D4342-31383735-30315430-473030
WARNING: at drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:9410 
bnx2x_init_one+0x1194/0x32b9
Hardware name: PowerEdge M620
  Modules linked in:
  Pid: 1, comm: swapper/0 Not tainted 3.2.63 #1
Call Trace:
warn_slowpath_common+0x78/0xb0
bnx2x_init_one+0x1194/0x32b9
bnx2x_init_one+0x1194/0x32b9
warn_slowpath_null+0x1b/0x20
bnx2x_init_one+0x1194/0x32b9
load_balance+0xb5/0x600
soft_cursor+0x19d/0x220
idr_get_empty_slot+0xf2/0x290
sysfs_link_sibling+0x6a/0xb0
__sysfs_add_one+0x5b/0x100
ida_get_new_above+0x49/0x1e0
kmem_cache_alloc+0xa9/0xb0
sysfs_add_one+0x1c/0xe0
sysfs_addrm_finish+0x12/0x90
sysfs_new_dirent+0x6d/0xf0
sysfs_do_create_link+0xbe/0x1f0
notifier_call_chain+0x44/0x60
pci_device_probe+0xf7/0x100
driver_probe_device+0x60/0x1f0
pci_match_device+0xf/0xa0
driver_probe_device+0x1f0/0x1f0
driver_attach+0x79/0x80
bus_for_each_dev+0x38/0x70
driver_attach+0x16/0x20
driver_probe_device+0x1f0/0x1f0
bus_add_driver+0x16f/0x250
pci_dev_put+0x20/0x20
driver_register+0x63/0x130
process_scheduled_works+0x30/0x30
cnic_init+0x7f/0x7f
__pci_register_driver+0x3c/0xa0
cnic_init+0x7f/0x7f
bnx2x_init+0x71/0x94
do_one_initcall+0x112/0x160
kernel_init+0x10f/0x1ab
do_early_param+0x77/0x77
start_kernel+0x327/0x327
kernel_thread_helper+0x6/0xd
bnx2x 0000:01:00.0: irq 132 for MSI/MSI-X
bnx2x 0000:01:00.0: irq 133 for MSI/MSI-X
bnx2x 0000:01:00.0: irq 134 for MSI/MSI-X
bnx2x 0000:01:00.0: irq 135 for MSI/MSI-X
bnx2x 0000:01:00.0: irq 136 for MSI/MSI-X
bnx2x 0000:01:00.0: irq 137 for MSI/MSI-X
bnx2x 0000:01:00.0: irq 138 for MSI/MSI-X
bnx2x 0000:01:00.0: irq 139 for MSI/MSI-X
bnx2x 0000:01:00.0: irq 140 for MSI/MSI-X
bnx2x 0000:01:00.0: irq 141 for MSI/MSI-X
bnx2x 0000:01:00.0: irq 142 for MSI/MSI-X
bnx2x 0000:01:00.0: irq 143 for MSI/MSI-X
bnx2x 0000:01:00.0: irq 144 for MSI/MSI-X
bnx2x 0000:01:00.0: irq 145 for MSI/MSI-X
bnx2x 0000:01:00.0: irq 146 for MSI/MSI-X
bnx2x 0000:01:00.0: irq 147 for MSI/MSI-X
bnx2x 0000:01:00.0: irq 148 for MSI/MSI-X
bnx2x 0000:01:00.0: eth0: Added CNIC device
bnx2x 0000:01:00.1: part number 394D4342-31383735-30315430-473030

-- 
Met vriendelijke groet,

Stefan Bottelier
Ocius Internet Services

E: Stefan.Bottelier@ocius.nl
T: +31 (0)20 716 39 09
W: http://www.ocius.nl
