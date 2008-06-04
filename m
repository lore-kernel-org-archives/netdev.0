From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: WARNING: at net/ipv4/tcp_input.c:2213
Date: Thu, 5 Jun 2008 01:50:49 +0400
Message-ID: <a4423d670806041450h17a2d3b1w40ea9ff8550a4b11@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: kernel-testers@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.226]:24226 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753343AbYFDVuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 17:50:50 -0400
Received: by wx-out-0506.google.com with SMTP id h29so225504wxd.4
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2008 14:50:49 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have got the following message:

WARNING: at net/ipv4/tcp_input.c:2213 tcp_mark_head_lost+0x14b/0x153()
Modules linked in:
Pid: 0, comm: swapper Not tainted 2.6.26-rc3-00332-gcbff290 #1
 [<c0119bbe>] warn_on_slowpath+0x41/0x6c
 [<c015a6b6>] ? check_bytes_and_report+0x21/0x8f
 [<c015a6b6>] ? check_bytes_and_report+0x21/0x8f
 [<c031875b>] tcp_mark_head_lost+0x14b/0x153
 [<c031a761>] tcp_ack+0x149e/0x16ef
 [<c031cf42>] tcp_rcv_established+0xe1/0x74b
 [<c0321d8b>] tcp_v4_do_rcv+0x25/0x150
 [<c0358def>] ? _spin_lock_nested+0x4f/0x57
 [<c0323500>] tcp_v4_rcv+0x45b/0x4a3
 [<c030ce5b>] ip_local_deliver+0x80/0xcb
 [<c030d241>] ip_rcv+0x39b/0x3c2
 [<c012bc13>] ? ktime_get_real+0x13/0x2f
 [<c02f9338>] netif_receive_skb+0x1ef/0x21d
 [<c02c3cce>] nv_napi_poll+0x200/0x612
 [<c02fb22f>] net_rx_action+0x77/0x156
 [<c011dccb>] __do_softirq+0x51/0x9e
 [<c0104781>] do_softirq+0x58/0xa8
 [<c013f997>] ? handle_fasteoi_irq+0x0/0xab
 [<c011dbf6>] irq_exit+0x3b/0x7c
 [<c0104890>] do_IRQ+0xbf/0xd4
 [<c010190a>] ? default_idle+0x0/0x4c
 [<c010362e>] common_interrupt+0x2e/0x34
 [<c010190a>] ? default_idle+0x0/0x4c
 [<c0101937>] ? default_idle+0x2d/0x4c
 [<c010186d>] cpu_idle+0x61/0x8e
 [<c034ee15>] rest_init+0x61/0x63
 =======================
---[ end trace 8a9d96a829374c21 ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2585 tcp_ack+0xd19/0x16ef()
Modules linked in:
Pid: 0, comm: swapper Tainted: G        W 2.6.26-rc3-00332-gcbff290 #1
 [<c0119bbe>] warn_on_slowpath+0x41/0x6c
 [<c0358e43>] ? _spin_lock+0x4c/0x53
 [<c02fbca4>] ? dev_queue_xmit+0x279/0x2a1
 [<c031020c>] ? ip_finish_output+0x20a/0x242
 [<c0310ddf>] ? ip_output+0x66/0x6a
 [<c030ee65>] ? ip_local_out+0x18/0x1b
 [<c0311066>] ? ip_queue_xmit+0x283/0x2e5
 [<c015b270>] ? __slab_alloc+0xb4/0x513
 [<c0319fdc>] tcp_ack+0xd19/0x16ef
 [<c031cf42>] tcp_rcv_established+0xe1/0x74b
 [<c0321d8b>] tcp_v4_do_rcv+0x25/0x150
 [<c0358def>] ? _spin_lock_nested+0x4f/0x57
 [<c0323500>] tcp_v4_rcv+0x45b/0x4a3
 [<c030ce5b>] ip_local_deliver+0x80/0xcb
 [<c030d241>] ip_rcv+0x39b/0x3c2
 [<c012bc13>] ? ktime_get_real+0x13/0x2f
 [<c02f9338>] netif_receive_skb+0x1ef/0x21d
 [<c02c3cce>] nv_napi_poll+0x200/0x612
 [<c02fb22f>] net_rx_action+0x77/0x156
 [<c011dccb>] __do_softirq+0x51/0x9e
 [<c0104781>] do_softirq+0x58/0xa8
 [<c013f997>] ? handle_fasteoi_irq+0x0/0xab
 [<c011dbf6>] irq_exit+0x3b/0x7c
 [<c0104890>] do_IRQ+0xbf/0xd4
 [<c010190a>] ? default_idle+0x0/0x4c
 [<c010362e>] common_interrupt+0x2e/0x34
 [<c010190a>] ? default_idle+0x0/0x4c
 [<c0101937>] ? default_idle+0x2d/0x4c
 [<c010186d>] cpu_idle+0x61/0x8e
 [<c034ee15>] rest_init+0x61/0x63
 =======================
---[ end trace 8a9d96a829374c21 ]---
