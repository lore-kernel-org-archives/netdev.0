From: Stephen Hemminger <stephen@networkplumber.org>
Subject: ixgbe: RTNL assertion failed
Date: Fri, 3 May 2013 12:09:07 -0700
Message-ID: <20130503120907.4f13d41b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:58443 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763294Ab3ECTJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 15:09:25 -0400
Received: by mail-da0-f51.google.com with SMTP id h15so892723dan.10
        for <netdev@vger.kernel.org>; Fri, 03 May 2013 12:09:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Running 3.9 kernel, ixgbe is splatting on resume from suspend.

[26430.213254] ixgbe 0000:01:00.0: setting latency timer to 64
[26430.213257] RTNL: assertion failed at /build/buildd-linux_3.2.41-2-amd64-Wvc92F/linux-3.2.41/net/core/dev.c (1758)
[26430.213259] Pid: 7839, comm: kworker/u:1 Not tainted 3.2.0-4-amd64 #1 Debian 3.2.41-2
[26430.213261] Call Trace:
[26430.213266]  [<ffffffff8128b89e>] ? netif_set_real_num_tx_queues+0x5c/0x15e
[26430.213286]  [<ffffffffa0051749>] ? ixgbe_set_num_queues+0x208/0x221 [ixgbe]
[26430.213287] sd 0:0:0:0: [sda] Starting disk
[26430.213292]  [<ffffffffa0054949>] ? ixgbe_init_interrupt_scheme+0x16/0x790 [ixgbe]
[26430.213299]  [<ffffffffa0055aae>] ? ixgbe_resume+0x7a/0xe3 [ixgbe]
[26430.213303]  [<ffffffff81255b7c>] ? pm_op+0xa1/0x141
[26430.213305]  [<ffffffff81255f40>] ? device_resume+0xa2/0xfc
[26430.213307]  [<ffffffff81255fae>] ? async_resume+0x14/0x38
[26430.213311]  [<ffffffff810648c4>] ? async_run_entry_fn+0x96/0x142
[26430.213313]  [<ffffffff8105b225>] ? process_one_work+0x161/0x264
[26430.213316]  [<ffffffff8105c1e6>] ? worker_thread+0xc2/0x145
[26430.213318]  [<ffffffff8105c124>] ? manage_workers.isra.25+0x15b/0x15b
[26430.213320]  [<ffffffff8105f321>] ? kthread+0x76/0x7e
[26430.213323]  [<ffffffff81354ab4>] ? kernel_thread_helper+0x4/0x10
[26430.213325]  [<ffffffff8105f2ab>] ? kthread_worker_fn+0x139/0x139
[26430.213327]  [<ffffffff81354ab0>] ? gs_change+0x13/0x13
