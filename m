From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Thu, 14 Feb 2008 13:00:16 +0000
Message-ID: <20080214130016.GA2583@ff.dom.local>
References: <47B0C9F7.5040200@katalix.com> <20080211224924.GA2863@ami.dom.local> <47B0DD1E.5000608@katalix.com> <20080211.213048.192442721.davem@davemloft.net> <47B17BCD.2070903@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.186]:5443 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755185AbYBNM7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2008 07:59:35 -0500
Received: by fk-out-0910.google.com with SMTP id z23so342025fkz.5
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2008 04:59:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47B17BCD.2070903@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

It seems, this nice report is still uncomplete: could you check if
there could have been something more yet?

Thanks,
Jarek P.

On Tue, Feb 12, 2008 at 10:58:21AM +0000, James Chapman wrote:
...
> Here is a trace from when we had _bh locks.
>
> Feb  5 16:26:32  ======================================================
> Feb  5 16:26:32  [ INFO: soft-safe -> soft-unsafe lock order detected ]
> Feb  5 16:26:32  2.6.24-core2 #1
> Feb  5 16:26:32  ------------------------------------------------------
> Feb  5 16:26:32  pppd/3224 [HC0[0]:SC0[2]:HE1:SE0] is trying to acquire:
...
> Feb  5 16:26:32  [<f8d7b84d>] e1000_clean+0x5d/0x290 [e1000]
> Feb  5 16:26:32  [<c039d580>] net_rx_action+0x1a0/0x2a0
> Feb  5 16:26:32  [<c039d43f>] net_rx_action+0x5f/0x2a0
> Feb  5 16:26:32  [<c0131e72>] __do_softirq+0x92/0x120
> Feb  5 16:26:32  [<c0131f78>] do_softirq+0x78/0x80
> Feb  5 16:26:32  [<c010b15a>] do_IRQ+0x4a/0xa0
> Feb  5 16:26:32  [<c0127af0>] finish_task_switch+0x0/0xc0
> Feb  5 16:26:32  [<c0108dcc>] common_interrupt+0x24/0x34
> Feb  5 16:26:32  [<c0108dd6>] common_interrupt+0x2e/0x34
> Feb  5 16:26:32  [<c01062d6>] mwait_idle_with_hints+0x46/0x60
> Feb  5 16:26:32  [<c0106550>] mwait_idle+0x0/0x20
> Feb  5 16:26:32  [<c0106694>] cpu_idle+0x74/0xe0
> Feb  5 16:26:32  [<c0536a9a>] start_kernel+0x30a/0x3a0
>
> -- 
> James Chapman
> Katalix Systems Ltd
> http://www.katalix.com
> Catalysts for your Embedded Linux software development
>
