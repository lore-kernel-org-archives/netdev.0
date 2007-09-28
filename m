From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: 2.6.23-rc8-mm2 - tcp_fastretrans_alert() WARNING
Date: Fri, 28 Sep 2007 17:42:40 +0200
Message-ID: <46FD20F0.3050909@fr.ibm.com>
References: <20070927022220.c76a7a6e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:42675 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752765AbXI1PnE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 11:43:04 -0400
In-Reply-To: <20070927022220.c76a7a6e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello ! 

Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc8/2.6.23-rc8-mm2/

I just found that warning in my logs. It seems that it's been 
happening since rc7-mm1 at least. 

Thanks !

C.

WARNING: at /home/legoater/linux/2.6.23-rc8-mm2/net/ipv4/tcp_input.c:2314 tcp_fastretrans_alert()

Call Trace:
 <IRQ>  [<ffffffff8040fdc3>] tcp_ack+0xcd6/0x1894
 [<ffffffff80411c79>] tcp_data_queue+0x5be/0xae7
 [<ffffffff80412b54>] tcp_rcv_established+0x61f/0x6df
 [<ffffffff80254146>] __lock_acquire+0x8a1/0xf1b
 [<ffffffff80419cfd>] tcp_v4_do_rcv+0x3e/0x394
 [<ffffffff8041a66f>] tcp_v4_rcv+0x61c/0x9a9
 [<ffffffff803ff1e3>] ip_local_deliver+0x1da/0x2a4
 [<ffffffff803ffb4e>] ip_rcv+0x583/0x5c9
 [<ffffffff8046d33f>] packet_rcv_spkt+0x19a/0x1a8
 [<ffffffff803e081c>] netif_receive_skb+0x2cf/0x2f5
 [<ffffffff88042505>] :tg3:tg3_poll+0x65d/0x8a4
 [<ffffffff803e09e8>] net_rx_action+0xb8/0x191
 [<ffffffff8023a927>] __do_softirq+0x5f/0xe0
 [<ffffffff8020c98c>] call_softirq+0x1c/0x28
 [<ffffffff8020e9c3>] do_softirq+0x3b/0xb8
 [<ffffffff8023aa1e>] irq_exit+0x4e/0x50
 [<ffffffff8020e7df>] do_IRQ+0xbd/0xd7
 [<ffffffff80209cb9>] mwait_idle+0x0/0x4d
 [<ffffffff8020bce6>] ret_from_intr+0x0/0xf
 <EOI>  [<ffffffff80209cfc>] mwait_idle+0x43/0x4d
 [<ffffffff802099fb>] enter_idle+0x22/0x24
 [<ffffffff80209c4f>] cpu_idle+0x9d/0xc0
 [<ffffffff80476a91>] rest_init+0x55/0x57
 [<ffffffff80630815>] start_kernel+0x2d6/0x2e2
 [<ffffffff80630134>] _sinittext+0x134/0x13b
