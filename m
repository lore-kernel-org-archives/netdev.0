From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 INFO: inconsistent lock state
Date: Fri, 30 Apr 2010 23:15:56 +0200
Message-ID: <20100430211556.GA4903@electric-eye.fr.zoreil.com>
References: <20100430182012.GA3329@swordfish.minsk.epam.com>
 <1272661149.2230.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1272661149.2230.11.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> :
[...]
> So we have following illegal chain (process context, not softirq)
> 
> rtl8169_reset_task() -> tl8169_rx_interrupt() -> netif_receive_skb()
> 
> And normally, commit 630b943c tried to change this chain to :
> 
> rtl8169_reset_task() -> tl8169_rx_interrupt() -> netif_rx()
> 
> I have no idea why it doesnt work.

630b943c appears to be in net-next.

Oops ?

-- 
Ueimor
