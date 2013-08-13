From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 OOPSen in rtl_rx
Date: Tue, 13 Aug 2013 23:15:34 +0200
Message-ID: <20130813211534.GA5635@electric-eye.fr.zoreil.com>
References: <20130813094314.GW3008@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48959 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758898Ab3HMVQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 17:16:08 -0400
Content-Disposition: inline
In-Reply-To: <20130813094314.GW3008@twins.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Zijlstra <peterz@infradead.org> :
[...]
> I've got an AMD x86_64 machine with two realtek NICs:
> 
> 01:08.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet (rev 10)
> 03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 06)

Which XID (see kernel dmesg) ?

[...]
> So all I've got to offer currently is a partial backtrace -- see
> attached image.

(no attachment)

> Partial transcribe:
> 
>   ? rtl8169_try_rx_copy.isra.77

/me scratches head.

You may check that pkt_size is > 0, <= ETH_FRAME_LEN (no jumbo ?) and
see if it helps.

-- 
Ueimor
