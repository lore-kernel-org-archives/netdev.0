From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] phonet: properly unshare skbs in phonet_rcv()
Date: Tue, 12 Jan 2016 15:47:18 -0500 (EST)
Message-ID: <20160112.154718.762462936767801736.davem@davemloft.net>
References: <5694A840.8030900@gmail.com>
	<1452608377.1223.13.camel@edumazet-glaptop2.roam.corp.google.com>
	<1452617880.1223.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ivo.g.dimitrov.75@gmail.com, courmisch@gmail.com,
	noureddine@arista.com, pali.rohar@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sre@kernel.org, linux-omap@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452617880.1223.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 12 Jan 2016 08:58:00 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Ivaylo Dimitrov reported a regression caused by commit 7866a621043f
> ("dev: add per net_device packet type chains").
> 
> skb->dev becomes NULL and we crash in __netif_receive_skb_core().
> 
> Before above commit, different kind of bugs or corruptions could happen
> without major crash.
> 
> But the root cause is that phonet_rcv() can queue skb without checking
> if skb is shared or not.
> 
> Many thanks to Ivaylo Dimitrov for his help, diagnosis and tests.
> 
> Reported-by: Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>
> Tested-by: Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Remi Denis-Courmont <courmisch@gmail.com>

Applied and queued up for -stable, th anks Eric.
