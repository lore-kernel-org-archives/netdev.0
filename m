From: poma <pomidorabelisima@gmail.com>
Subject: Some warnings for skge - netpoll/netconsole induced
Date: Wed, 07 Jan 2015 06:29:04 +0100
Message-ID: <54ACC420.90304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:37152 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbbAGFf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 00:35:27 -0500
Received: by mail-wg0-f50.google.com with SMTP id a1so517025wgh.23
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 21:35:25 -0800 (PST)
Received: from localhost (iskon7306.duo.carnet.hr. [31.147.124.138])
        by mx.google.com with ESMTPSA id je12sm1120038wic.22.2015.01.06.21.29.04
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jan 2015 21:29:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------------[ cut here ]------------
WARNING: CPU: 1 PID: 2991 at net/core/netpoll.c:362 netpoll_send_skb_on_dev+0x25e/0x270()
netpoll_send_skb_on_dev(): enp1s6 enabled interrupts in poll (skge_xmit_frame+0x0/0x680 [skge])
...
CPU: 1 PID: 2991 Comm: modprobe Not tainted 3.19.0-0.rc3.git0.1.fc21.x86_64 #1
...
Call Trace:
 [<ffffffff8176cf2d>] dump_stack+0x45/0x57
 [<ffffffff8109b09a>] warn_slowpath_common+0x8a/0xc0
 [<ffffffff8109b125>] warn_slowpath_fmt+0x55/0x70
 [<ffffffff813a2aab>] ? delay_tsc+0x3b/0x70
 [<ffffffffa00d3be0>] ? skge_rx_setup.isra.44+0x180/0x180 [skge]
 [<ffffffff8167518e>] netpoll_send_skb_on_dev+0x25e/0x270
 [<ffffffff81675462>] netpoll_send_udp+0x2c2/0x410
 [<ffffffffa079b92f>] write_msg+0xcf/0x140 [netconsole]
 [<ffffffff810ef2aa>] call_console_drivers.constprop.22+0xaa/0xf0
 [<ffffffff810f0992>] console_unlock+0x362/0x450
 [<ffffffff810f0e30>] vprintk_emit+0x3b0/0x550
 [<ffffffff810f1159>] vprintk_default+0x29/0x40
 [<ffffffff8176b42c>] printk+0x55/0x6b
 [<ffffffff810f15cd>] register_console+0x1bd/0x380
 [<ffffffffa07a0000>] ? 0xffffffffa07a0000
 [<ffffffffa07a01c4>] init_netconsole+0x1c4/0x1000 [netconsole]
 [<ffffffffa07a0000>] ? 0xffffffffa07a0000
 [<ffffffff81002148>] do_one_initcall+0xd8/0x210
 [<ffffffff811de302>] ? __vunmap+0xa2/0x100
 [<ffffffff8111ef16>] load_module+0x2256/0x2800
 [<ffffffff8111a750>] ? store_uevent+0x70/0x70
 [<ffffffff8111f58d>] SyS_init_module+0xcd/0x120
 [<ffffffff81773929>] system_call_fastpath+0x12/0x17
---[ end trace 257df3717d2db089 ]---
