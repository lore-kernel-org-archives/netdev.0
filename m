From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: do not pretend FRAGLIST support
Date: Mon, 02 Dec 2013 17:17:08 -0500 (EST)
Message-ID: <20131202.171708.287579418417500322.davem@davemloft.net>
References: <20131202.111600.1622488165507147936.davem@davemloft.net>
	<1386001999.5352.51.camel@edumazet-glaptop2.roam.corp.google.com>
	<1386003073.5352.58.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, puzman@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, cascardo@linux.vnet.ibm.com,
	anirudh@xilinx.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386003073.5352.58.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Dec 2013 08:51:13 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Few network drivers really supports frag_list : virtual drivers.
> 
> Some drivers wrongly advertise NETIF_F_FRAGLIST feature.
> 
> If skb with a frag_list is given to them, packet on the wire will be
> corrupt.
> 
> Remove this flag, as core networking stack will make sure to
> provide packets that can be sent without corruption.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Good catch, applied and queued up for -stable.
