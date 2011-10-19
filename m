From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: System call 'sendmsg' of process ospfd (quagga)
 causes kernel oops
Date: Wed, 19 Oct 2011 03:30:52 -0400 (EDT)
Message-ID: <20111019.033052.851679720607111734.davem@davemloft.net>
References: <20111018134537.GA17055@gondor.apana.org.au>
	<20111019.030914.218521668377472155.davem@davemloft.net>
	<1319008713.17914.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, evonlanthen@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	timo.teras@iki.fi
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319008713.17914.8.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 19 Oct 2011 09:18:33 +0200

> Seems fine (Maybe do the +15 in caller site ?), but we also have other
> problematic cases, using alloc_skb() only...

Ok, which ones operate over these problematic GRE tunnels?
