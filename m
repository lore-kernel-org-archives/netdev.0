From: Andi Kleen <ak@suse.de>
Subject: Re: way of figuring out total number of retransmitted packets on a TCP socket?
Date: Thu, 21 Oct 2004 01:04:05 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020230405.GE995@wotan.suse.de>
References: <20041020130134.GC24757@xi.wantstofly.org> <20041020151448.51209278.davem@davemloft.net> <20041020223547.GJ29583@xi.wantstofly.org> <20041020155352.1c9b70f6.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041020155352.1c9b70f6.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I agree.  We could easily add the thing you are looking for.  It's
> just another statistic, zero'd at socket creation time and incremented
> right under the line which reads:
> 
> 		/* Update global TCP statistics. */
> 		TCP_INC_STATS(TCP_MIB_RETRANSSEGS);
> 
> in tcp_retransmit_skb().
> 
> I'll add this for you.

Is it really necessary? Our struct sock is already bloated enough 
as is ... If Lennert needs it for some obscure purpose it's probably
better if he just does it locally.

-Andi
