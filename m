From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix inverted test in __skb_recv_datagram
Date: Tue, 08 Dec 2015 11:31:29 -0500 (EST)
Message-ID: <20151208.113129.263389829273977789.davem@davemloft.net>
References: <87vb8925vx.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<20151207.222827.1680789119862020474.davem@davemloft.net>
	<87h9jt809v.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: rweikusat@mobileactivedefense.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87h9jt809v.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Date: Tue, 08 Dec 2015 14:47:56 +0000

> As the kernel generally uses negated error numbers, *err needs to be
> compared with -EAGAIN (d'oh).
> 
> Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>
> Fixes: ea3793ee29d3 ("core: enable more fine-grained datagram reception control")

Applied, thanks.

Please, in the future, place proper subsystem prefixes in your
Subject lines.  In this case, "net: " would have been appropriate
and it wouldn't be the end of the world if you capitalized
your commit header line too.

I fixed both of these things while installing your change.

Thanks.
