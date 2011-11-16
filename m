From: David Miller <davem@davemloft.net>
Subject: Re: [3.1] Divide by zero in __tcp_select_window()
Date: Wed, 16 Nov 2011 16:58:35 -0500 (EST)
Message-ID: <20111116.165835.803145377567644412.davem@davemloft.net>
References: <20111114.153608.2064552703690099046.davem@davemloft.net>
	<1321304216.2719.23.camel@edumazet-laptop>
	<20111116195419.GE24411@hostway.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, tglx@linutronix.de, netdev@vger.kernel.org,
	a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org,
	davej@redhat.com, schwidefsky@de.ibm.com, mingo@elte.hu
To: sim@hostway.ca
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111116195419.GE24411@hostway.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Kirby <sim@hostway.ca>
Date: Wed, 16 Nov 2011 11:54:19 -0800

> Looks good, thanks! Working on ~25 boxes without issue for >36 hours.
> 
> Simon-
> 
> Tested-by: Simon Kirby <sim@hostway.ca>
> 
>> [PATCH] tcp: clear xmit timers in tcp_v4_syn_recv_sock()

Applied and queued up for -stable, thanks everyone.
