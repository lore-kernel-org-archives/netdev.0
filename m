From: maximilian attems <max@stro.at>
Subject: e1000e oops
Date: Fri, 5 Oct 2007 15:11:15 +0200
Message-ID: <20071005131115.GA31453@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:58940 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011AbXJENL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 09:11:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linux tau 2.6.23-rc8-mm2-686 #1 SMP Wed Oct 3 23:56:32 CEST 2007 i686
GNU/Linux

eth0 renamed to eth1
sysfs: duplicate filename 'eth1' can not be created
WARNING: at fs/sysfs/dir.c:433 sysfs_add_one()
 [<c0104f9c>] dump_trace+0x68/0x1d5
 [<c0105121>] show_trace_log_lvl+0x18/0x2c
 [<c0105b9b>] show_trace+0xf/0x11
 [<c0105c81>] dump_stack+0x12/0x14
 [<c01ac02e>] sysfs_add_one+0x54/0xb8
 [<c01acc2a>] sysfs_create_link+0xb3/0x125
 [<c023c05f>] device_rename+0x13d/0x196
 [<c025a970>] dev_change_name+0x137/0x205
 [<c025b12c>] dev_ioctl+0x357/0x44f
 [<c017b05f>] do_ioctl+0x1f/0x62
 [<c017b2d9>] vfs_ioctl+0x237/0x249
 [<c017b330>] sys_ioctl+0x45/0x5d
 [<c0103eda>] syscall_call+0x7/0xb
 [<b7edbde4>] 0xb7edbde4
 =======================
net eth1: device_rename: sysfs_create_symlink failed (-17)

00:19.0 Ethernet controller [0200]: Intel Corporation 82801I (ICH9 Family) Gigabit Ethernet Controller [8086:294c] (rev 02)
        Subsystem: Intel Corporation Unknown device [8086:0001]
        Flags: bus master, fast devsel, latency 0, IRQ 218
        Memory at 50380000 (32-bit, non-prefetchable) [size=128K]
        Memory at 503a4000 (32-bit, non-prefetchable) [size=4K]
        I/O ports at 20e0 [size=32]
        Capabilities: [c8] Power Management version 2
        Capabilities: [d0] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
        Capabilities: [e0] Vendor Specific Information


no idea if aboves belongs to netdev or sysfs dep.

-- 
maks
