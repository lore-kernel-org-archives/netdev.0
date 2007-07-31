From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [OOPS] 2.6.23-rc1 Seems to be network related
Date: Tue, 31 Jul 2007 16:43:50 -0700
Message-ID: <20070731164350.9084f5de.akpm@linux-foundation.org>
References: <200708010135.23421.bonganilinux@mweb.co.za>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bongani Hlope <bonganilinux@mweb.co.za>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44707 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752024AbXGaXpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 19:45:24 -0400
In-Reply-To: <200708010135.23421.bonganilinux@mweb.co.za>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 1 Aug 2007 01:35:23 +0200
Bongani Hlope <bonganilinux@mweb.co.za> wrote:

> I got this partial Oops on my work laptop (DELL D800), while using the linux 
> 2.6.23-rc1 kernel. I've been using this kernel ever since it was released and 
> this is the first and only time it did not boot. It was around the time it 
> should have been trying to connect to my linksys wireless router (which has 
> been working fine everyday since the 2.6.23-rc1 kernel was released).
> 
> I copied what was on screen by hand, so some info is missing. I don't know how 
> to reproduce it.
> 
> Call Trace:
> [<c0104cbc>] show_trace_log_lvl+0x1a/0x2f
> [<c0104d6c>] show_stack_log_lvl+0x9b/0xa3
> [<c0104f36>] show_registers+0x1c2/0x2db
> [<c0105151>] die+0x02/0x1de
> [<c01052b6>] do_trap+0x89/0xa2
> [<c010558e>] do_invalid_op+0x88/0x92
> [<c035a162>] error_code+0x6a/0x70
> [<c0114efa>] kmap_atomic+0xe/0x10
> [<c014a29c>] get_page_from_freelist+0x24c/0x3...
> [<c015dd06>] __alloc_pages+0x53/0x27d
> [<c015da60>] kmem_cache_alloc+0x32/0x68
> [<c02e5065>] dst_alloc+0x28/0x60
> [<c02f45fe>] ip_route_input+0x9b9/0xbba
> [<c0314835>] arp_process+0x155/0x4e1
> [<c0314caa>] arp_rcv+0xe9/0xfd
> [<c02e1660>] netif_receive_skb+0x16e/0x1eb
> [<c02e2efa>] process_backlog+0x71/0xda
> [<c02e2fb9>] net_rx_action+0x56/0xee
> [<c011f437>] __do_softirq+0x38/0x7a
> [<c0106145>] do_soft_irq+0x41/0x91
> [<c011f3c5>] irq_exit+0x2c/0x66
> [<c010644a>] do_IRQ+0xb7/0xcd
> [<c01047eb>] common_interrupt+0x23/0x28
> [<c0151f87>] handle_mm_fault+0x1fe/0x57e
> [<c035a162>] error_code+0x6a/0x70
> =======================
> EIP: [<c0114e87>] kmap_atomic_prot+0x27/0x8..

Thanks.  Commit b8c1c5da1520977cb55a358f20fc09567d40cad9 should
have fixed this.
