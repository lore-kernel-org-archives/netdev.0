From: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Subject: Re: 2.6.24-rc5-mm1
Date: Fri, 14 Dec 2007 19:38:08 +0530
Message-ID: <20071214140808.GA3033@linux.vnet.ibm.com>
References: <20071213024050.7d6e5f3e.akpm@linux-foundation.org>
Reply-To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753928AbXLNOJJ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071213024050.7d6e5f3e.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

I hit this just now. Not sure if I can reproduce it though.

WARNING: at net/ipv4/tcp_input.c:2533 tcp_fastretrans_alert()
Pid: 4624, comm: yield Not tainted 2.6.24-rc5-mm1 #5
 [<c010582a>] show_trace_log_lvl+0x12/0x22
 [<c0105847>] show_trace+0xd/0xf
 [<c0105959>] dump_stack+0x57/0x5e
 [<c03db95b>] tcp_fastretrans_alert+0xde/0x5bd
 [<c03dcab2>] tcp_ack+0x236/0x2e4
 [<c03dea01>] tcp_rcv_established+0x51e/0x5c0
 [<c03e56f1>] tcp_v4_do_rcv+0x22/0xc4
 [<c03e5c49>] tcp_v4_rcv+0x4b6/0x7f5
 [<c03cd5ad>] ip_local_deliver_finish+0xb9/0x169
 [<c03cd68a>] ip_local_deliver+0x2d/0x34
 [<c03cd91d>] ip_rcv_finish+0x28c/0x2ab
 [<c03cdb16>] ip_rcv+0x1da/0x204
 [<c03b800a>] netif_receive_skb+0x23c/0x26f
 [<c02db326>] tg3_rx+0x246/0x353
 [<c02db4ac>] tg3_poll_work+0x79/0x86
 [<c02db4e8>] tg3_poll+0x2f/0x16f
 [<c03b822b>] net_rx_action+0xbb/0x1a8
 [<c0129596>] __do_softirq+0x73/0xe6
 [<c0129642>] do_softirq+0x39/0x51
 [<c01296c0>] irq_exit+0x47/0x49
 [<c01064f4>] do_IRQ+0x55/0x69
 [<c0105492>] common_interrupt+0x2e/0x34
 =======================

-- 
regards,
Dhaval
