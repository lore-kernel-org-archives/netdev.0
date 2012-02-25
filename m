From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: WARNING: at net/ipv4/tcp_input.c:3418
Date: Sat, 25 Feb 2012 19:34:45 +0100
Message-ID: <20120225183445.GB5661@x4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ud10.udmedia.de ([194.117.254.50]:42751 "EHLO
	mail.ud10.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755861Ab2BYSl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Feb 2012 13:41:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've hit the following warnings today while using bittorrent:

------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3418 tcp_ack+0xf8f/0x11a0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Not tainted 3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142430f>] ? tcp_ack+0xf8f/0x11a0
 [<ffffffff81424e4d>] ? tcp_rcv_established+0x28d/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa623 ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3048 tcp_fastretrans_alert+0xe9a/0xee0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142315a>] ? tcp_fastretrans_alert+0xe9a/0xee0
 [<ffffffff814238ac>] ? tcp_ack+0x52c/0x11a0
 [<ffffffff81424e4d>] ? tcp_rcv_established+0x28d/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa624 ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2885 tcp_fastretrans_alert+0xecd/0xee0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142318d>] ? tcp_fastretrans_alert+0xecd/0xee0
 [<ffffffff814238ac>] ? tcp_ack+0x52c/0x11a0
 [<ffffffff81424e4d>] ? tcp_rcv_established+0x28d/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa625 ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3418 tcp_ack+0xf8f/0x11a0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142430f>] ? tcp_ack+0xf8f/0x11a0
 [<ffffffff81424f93>] ? tcp_rcv_established+0x3d3/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff811c47e7>] ? swiotlb_tbl_unmap_single+0x47/0x120
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa626 ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3048 tcp_fastretrans_alert+0xe9a/0xee0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142315a>] ? tcp_fastretrans_alert+0xe9a/0xee0
 [<ffffffff814238ac>] ? tcp_ack+0x52c/0x11a0
 [<ffffffff81424f93>] ? tcp_rcv_established+0x3d3/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff811c47e7>] ? swiotlb_tbl_unmap_single+0x47/0x120
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa627 ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2885 tcp_fastretrans_alert+0xecd/0xee0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142318d>] ? tcp_fastretrans_alert+0xecd/0xee0
 [<ffffffff814238ac>] ? tcp_ack+0x52c/0x11a0
 [<ffffffff81424f93>] ? tcp_rcv_established+0x3d3/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff811c47e7>] ? swiotlb_tbl_unmap_single+0x47/0x120
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa628 ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3418 tcp_ack+0xf8f/0x11a0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142430f>] ? tcp_ack+0xf8f/0x11a0
 [<ffffffff81424f93>] ? tcp_rcv_established+0x3d3/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa629 ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3048 tcp_fastretrans_alert+0xe9a/0xee0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142315a>] ? tcp_fastretrans_alert+0xe9a/0xee0
 [<ffffffff814238ac>] ? tcp_ack+0x52c/0x11a0
 [<ffffffff81424f93>] ? tcp_rcv_established+0x3d3/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa62a ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2885 tcp_fastretrans_alert+0xecd/0xee0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142318d>] ? tcp_fastretrans_alert+0xecd/0xee0
 [<ffffffff814238ac>] ? tcp_ack+0x52c/0x11a0
 [<ffffffff81424f93>] ? tcp_rcv_established+0x3d3/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa62b ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3418 tcp_ack+0xf8f/0x11a0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142430f>] ? tcp_ack+0xf8f/0x11a0
 [<ffffffff81424f93>] ? tcp_rcv_established+0x3d3/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa62c ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3048 tcp_fastretrans_alert+0xe9a/0xee0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142315a>] ? tcp_fastretrans_alert+0xe9a/0xee0
 [<ffffffff814238ac>] ? tcp_ack+0x52c/0x11a0
 [<ffffffff81424f93>] ? tcp_rcv_established+0x3d3/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa62d ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2885 tcp_fastretrans_alert+0xecd/0xee0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142318d>] ? tcp_fastretrans_alert+0xecd/0xee0
 [<ffffffff814238ac>] ? tcp_ack+0x52c/0x11a0
 [<ffffffff81424f93>] ? tcp_rcv_established+0x3d3/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa62e ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3418 tcp_ack+0xf8f/0x11a0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142430f>] ? tcp_ack+0xf8f/0x11a0
 [<ffffffff81424f93>] ? tcp_rcv_established+0x3d3/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff813d1071>] ? __kfree_skb+0x11/0xa0
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa62f ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3048 tcp_fastretrans_alert+0xe9a/0xee0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142315a>] ? tcp_fastretrans_alert+0xe9a/0xee0
 [<ffffffff814238ac>] ? tcp_ack+0x52c/0x11a0
 [<ffffffff81424f93>] ? tcp_rcv_established+0x3d3/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff813d1071>] ? __kfree_skb+0x11/0xa0
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa630 ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2885 tcp_fastretrans_alert+0xecd/0xee0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142318d>] ? tcp_fastretrans_alert+0xecd/0xee0
 [<ffffffff814238ac>] ? tcp_ack+0x52c/0x11a0
 [<ffffffff81424f93>] ? tcp_rcv_established+0x3d3/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff813d1071>] ? __kfree_skb+0x11/0xa0
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa631 ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3418 tcp_ack+0xf8f/0x11a0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142430f>] ? tcp_ack+0xf8f/0x11a0
 [<ffffffff81424d83>] ? tcp_rcv_established+0x1c3/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa632 ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3048 tcp_fastretrans_alert+0xe9a/0xee0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142315a>] ? tcp_fastretrans_alert+0xe9a/0xee0
 [<ffffffff814238ac>] ? tcp_ack+0x52c/0x11a0
 [<ffffffff81424d83>] ? tcp_rcv_established+0x1c3/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa633 ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2885 tcp_fastretrans_alert+0xecd/0xee0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142318d>] ? tcp_fastretrans_alert+0xecd/0xee0
 [<ffffffff814238ac>] ? tcp_ack+0x52c/0x11a0
 [<ffffffff81424d83>] ? tcp_rcv_established+0x1c3/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa634 ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3418 tcp_ack+0xf8f/0x11a0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142430f>] ? tcp_ack+0xf8f/0x11a0
 [<ffffffff81424e4d>] ? tcp_rcv_established+0x28d/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa635 ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3048 tcp_fastretrans_alert+0xe9a/0xee0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142315a>] ? tcp_fastretrans_alert+0xe9a/0xee0
 [<ffffffff814238ac>] ? tcp_ack+0x52c/0x11a0
 [<ffffffff81424e4d>] ? tcp_rcv_established+0x28d/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa636 ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2885 tcp_fastretrans_alert+0xecd/0xee0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142318d>] ? tcp_fastretrans_alert+0xecd/0xee0
 [<ffffffff814238ac>] ? tcp_ack+0x52c/0x11a0
 [<ffffffff81424e4d>] ? tcp_rcv_established+0x28d/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa637 ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3418 tcp_ack+0xf8f/0x11a0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142430f>] ? tcp_ack+0xf8f/0x11a0
 [<ffffffff81424e4d>] ? tcp_rcv_established+0x28d/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa638 ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3048 tcp_fastretrans_alert+0xe9a/0xee0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142315a>] ? tcp_fastretrans_alert+0xe9a/0xee0
 [<ffffffff814238ac>] ? tcp_ack+0x52c/0x11a0
 [<ffffffff81424e4d>] ? tcp_rcv_established+0x28d/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa639 ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2885 tcp_fastretrans_alert+0xecd/0xee0()
Hardware name: System Product Name
Pid: 14513, comm: cc1plus Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142318d>] ? tcp_fastretrans_alert+0xecd/0xee0
 [<ffffffff814238ac>] ? tcp_ack+0x52c/0x11a0
 [<ffffffff81424e4d>] ? tcp_rcv_established+0x28d/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI> 
---[ end trace 6bd1602ca76fa63a ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3418 tcp_ack+0xf8f/0x11a0()
Hardware name: System Product Name
Pid: 0, comm: swapper/3 Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142430f>] ? tcp_ack+0xf8f/0x11a0
 [<ffffffff81424e4d>] ? tcp_rcv_established+0x28d/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI>  [<ffffffff8103a220>] ? default_idle+0x20/0x40
 [<ffffffff8103a292>] ? amd_e400_idle+0x52/0x100
 [<ffffffff81031156>] ? cpu_idle+0xb6/0xe0
---[ end trace 6bd1602ca76fa63b ]---
Leak s=4294967295 1
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3418 tcp_ack+0xf8f/0x11a0()
Hardware name: System Product Name
Pid: 0, comm: swapper/3 Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142430f>] ? tcp_ack+0xf8f/0x11a0
 [<ffffffff8142484f>] ? tcp_validate_incoming+0x4f/0x320
 [<ffffffff81424e4d>] ? tcp_rcv_established+0x28d/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI>  [<ffffffff8103a220>] ? default_idle+0x20/0x40
 [<ffffffff8103a292>] ? amd_e400_idle+0x52/0x100
 [<ffffffff81031156>] ? cpu_idle+0xb6/0xe0
---[ end trace 6bd1602ca76fa63c ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3048 tcp_fastretrans_alert+0xe9a/0xee0()
Hardware name: System Product Name
Pid: 0, comm: swapper/3 Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142315a>] ? tcp_fastretrans_alert+0xe9a/0xee0
 [<ffffffff814238ac>] ? tcp_ack+0x52c/0x11a0
 [<ffffffff8142484f>] ? tcp_validate_incoming+0x4f/0x320
 [<ffffffff81424e4d>] ? tcp_rcv_established+0x28d/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI>  [<ffffffff8103a220>] ? default_idle+0x20/0x40
 [<ffffffff8103a292>] ? amd_e400_idle+0x52/0x100
 [<ffffffff81031156>] ? cpu_idle+0xb6/0xe0
---[ end trace 6bd1602ca76fa63d ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3418 tcp_ack+0xf8f/0x11a0()
Hardware name: System Product Name
Pid: 842, comm: syslog-ng Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142430f>] ? tcp_ack+0xf8f/0x11a0
 [<ffffffff81424e4d>] ? tcp_rcv_established+0x28d/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff81089453>] ? tick_handle_oneshot_broadcast+0xf3/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI>  [<ffffffff810d6a5b>] ? kmem_cache_alloc+0x3b/0xa0
 [<ffffffff81113677>] ? fsnotify_create_event+0x37/0x140
 [<ffffffff811129aa>] ? send_to_group.isra.1+0x16a/0x1a0
 [<ffffffff81112e5a>] ? fsnotify+0x2fa/0x340
 [<ffffffff810d6b74>] ? kmem_cache_free+0x14/0xa0
 [<ffffffff81112f6d>] ? __fsnotify_parent+0xcd/0xe0
 [<ffffffff810f708d>] ? notify_change+0x24d/0x2e0
 [<ffffffff810dc961>] ? chown_common.isra.16+0x61/0xa0
 [<ffffffff810dd6f7>] ? sys_fchown+0x57/0x80
 [<ffffffff81478122>] ? system_call_fastpath+0x16/0x1b
---[ end trace 6bd1602ca76fa63e ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3048 tcp_fastretrans_alert+0xe9a/0xee0()
Hardware name: System Product Name
Pid: 842, comm: syslog-ng Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142315a>] ? tcp_fastretrans_alert+0xe9a/0xee0
 [<ffffffff814238ac>] ? tcp_ack+0x52c/0x11a0
 [<ffffffff81424e4d>] ? tcp_rcv_established+0x28d/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff81089453>] ? tick_handle_oneshot_broadcast+0xf3/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI>  [<ffffffff810d6a5b>] ? kmem_cache_alloc+0x3b/0xa0
 [<ffffffff81113677>] ? fsnotify_create_event+0x37/0x140
 [<ffffffff811129aa>] ? send_to_group.isra.1+0x16a/0x1a0
 [<ffffffff81112e5a>] ? fsnotify+0x2fa/0x340
 [<ffffffff810d6b74>] ? kmem_cache_free+0x14/0xa0
 [<ffffffff81112f6d>] ? __fsnotify_parent+0xcd/0xe0
 [<ffffffff810f708d>] ? notify_change+0x24d/0x2e0
 [<ffffffff810dc961>] ? chown_common.isra.16+0x61/0xa0
 [<ffffffff810dd6f7>] ? sys_fchown+0x57/0x80
 [<ffffffff81478122>] ? system_call_fastpath+0x16/0x1b
---[ end trace 6bd1602ca76fa63f ]---
------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:3418 tcp_ack+0xf8f/0x11a0()
Hardware name: System Product Name
Pid: 0, comm: swapper/3 Tainted: G        W    3.3.0-rc4-00091-gbb4c7e9-dirty #3
Call Trace:
 <IRQ>  [<ffffffff81055c40>] ? warn_slowpath_common+0x60/0xa0
 [<ffffffff8142430f>] ? tcp_ack+0xf8f/0x11a0
 [<ffffffff81424e4d>] ? tcp_rcv_established+0x28d/0x720
 [<ffffffff8142c4ed>] ? tcp_v4_do_rcv+0x8d/0x2a0
 [<ffffffff8142e0d9>] ? tcp_v4_rcv+0x5f9/0x720
 [<ffffffff8140dcbd>] ? ip_local_deliver_finish+0x5d/0x140
 [<ffffffff813d9af6>] ? __netif_receive_skb+0x2d6/0x3a0
 [<ffffffff813dcf9a>] ? netif_receive_skb+0x1a/0x80
 [<ffffffff813d0d79>] ? __netdev_alloc_skb+0x19/0x40
 [<ffffffff8131baec>] ? atl1e_clean+0x1ac/0x3c0
 [<ffffffff813dd9d9>] ? net_rx_action+0x79/0x120
 [<ffffffff8105b3ed>] ? __do_softirq+0x8d/0x120
 [<ffffffff810935f9>] ? handle_irq_event_percpu+0x79/0x140
 [<ffffffff8147928c>] ? call_softirq+0x1c/0x26
 [<ffffffff810341bd>] ? do_softirq+0x3d/0x80
 [<ffffffff8105b6e5>] ? irq_exit+0xa5/0xc0
 [<ffffffff8103408d>] ? do_IRQ+0x4d/0xc0
 [<ffffffff81477a2b>] ? common_interrupt+0x6b/0x6b
 <EOI>  [<ffffffff8103a220>] ? default_idle+0x20/0x40
 [<ffffffff8103a292>] ? amd_e400_idle+0x52/0x100
 [<ffffffff81031156>] ? cpu_idle+0xb6/0xe0
---[ end trace 6bd1602ca76fa640 ]---
Leak s=4294967295 3

-- 
Markus
