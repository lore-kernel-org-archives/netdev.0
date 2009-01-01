From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: 2.6.28-03117: WARNING: at net/ipv4/tcp_input.c:2504
	tcp_mark_head_lost()
Date: Thu, 1 Jan 2009 15:41:14 +0300
Message-ID: <20090101124114.GA4281@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:6842 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755952AbZAAMlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2009 07:41:24 -0500
Received: by fg-out-1718.google.com with SMTP id 19so2168575fgg.17
        for <netdev@vger.kernel.org>; Thu, 01 Jan 2009 04:41:21 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WARNING: at net/ipv4/tcp_input.c:2504 tcp_mark_head_lost+0x1df/0x200()
 Modules linked in: w83627hf hwmon_vid i2c_nforce2
 Pid: 0, comm: swapper Not tainted 2.6.28-03117-g6a94cb7 #1
 Call Trace:
  [<c040f321>] ? printk+0x18/0x1f
  [<c0128354>] warn_on_slowpath+0x54/0x80
  [<c014bd25>] ? __lock_acquire+0x2c5/0x1000
  [<c014b74c>] ? trace_hardirqs_on_caller+0x7c/0x160
  [<c0399041>] ? dev_queue_xmit+0xe1/0x5d0
  [<c014bd25>] ? __lock_acquire+0x2c5/0x1000
  [<c014862b>] ? trace_hardirqs_off+0xb/0x10
  [<c03bfaff>] tcp_mark_head_lost+0x1df/0x200
  [<c03c561d>] tcp_ack+0x18dd/0x1ef0
  [<c03c5ec9>] tcp_rcv_established+0x299/0x5b0
  [<c03cc840>] tcp_v4_do_rcv+0x90/0x1b0
  [<c0411b5c>] ? _spin_lock_nested+0x6c/0x80
  [<c03cdd27>] ? tcp_v4_rcv+0x467/0x5f0
  [<c03cddf2>] tcp_v4_rcv+0x532/0x5f0
  [<c03b149c>] ip_local_deliver+0x6c/0xe0
  [<c03b12b5>] ip_rcv+0x2b5/0x430
  [<c0396b60>] netif_receive_skb+0x240/0x310
  [<c03484d8>] nv_napi_poll+0x298/0x670
  [<c014b83b>] ? trace_hardirqs_on+0xb/0x10
  [<c039a636>] net_rx_action+0x106/0x1b0
  [<c012cf0f>] __do_softirq+0x7f/0x120
  [<c012d015>] do_softirq+0x65/0x70
  [<c012d0ad>] irq_exit+0x8d/0xa0
  [<c0105525>] do_IRQ+0x95/0xc0
  [<c014b7de>] ? trace_hardirqs_on_caller+0x10e/0x160
  [<c0103a2c>] common_interrupt+0x2c/0x34
  [<c0109fbf>] ? default_idle+0x4f/0x60
  [<c0101ba5>] cpu_idle+0x55/0xb0
  [<c0405781>] rest_init+0x61/0x70

