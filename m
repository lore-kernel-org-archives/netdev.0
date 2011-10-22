From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: fix tigon3_dma_hwbug_workaround()
Date: Sat, 22 Oct 2011 03:30:20 -0400 (EDT)
Message-ID: <20111022.033020.2073551679260143993.davem@davemloft.net>
References: <CAEbykaVJneQ0ozUvYh2PRn-p_BowL4z4_4Y8EFCdO9mOsNX7OQ@mail.gmail.com>
	<1319265470.6180.13.camel@edumazet-laptop>
	<1319268338.6180.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ari.m.savolainen@gmail.com, roy.qing.li@gmail.com,
	richardcochran@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319268338.6180.20.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 22 Oct 2011 09:25:38 +0200

> Ari got kernel panics using tg3 NIC, and bisected to 2669069aacc9 "tg3:
> enable transmit time stamping."
> 
> This is because tigon3_dma_hwbug_workaround() might alloc a new skb and
> free the original. We panic when skb_tx_timestamp() is called on freed
> skb.
> 
> Reported-by: Ari Savolainen <ari.m.savolainen@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
