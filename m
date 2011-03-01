From: David Miller <davem@davemloft.net>
Subject: Re: txqueuelen has wrong units; should be time
Date: Mon, 28 Feb 2011 23:25:02 -0800 (PST)
Message-ID: <20110228.232502.226763923.davem@davemloft.net>
References: <AANLkTinFZu5AgfhO6PoA7C1NTGSfD8HH0KXq_o-mHEJF@mail.gmail.com>
	<20110228.201852.193726064.davem@davemloft.net>
	<AANLkTi=eDQh9Kvr9N_dTC5Cnbcfb+DbO-6tLxkZiEp9v@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnwheffner@gmail.com, linville@tuxdriver.com,
	eric.dumazet@gmail.com, jussi.kivilinna@mbnet.fi, swmike@swm.pp.se,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: acahalan@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=eDQh9Kvr9N_dTC5Cnbcfb+DbO-6tLxkZiEp9v@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Albert Cahalan <acahalan@gmail.com>
Date: Tue, 1 Mar 2011 01:54:09 -0500

> In case it makes you feel any better, consider two cases
> where synchronous feedback is already impossible.
> One is when you're routing packets that merely pass through.
> The other is when some other box is doing that to you.
> Either way, packets go bye-bye and nobody tells TCP.

I consider ECN quite synchronous, and routers will set ECN bits to
propagate congestion information when they do or are about to drop
packets.
