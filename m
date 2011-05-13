From: David Miller <davem@davemloft.net>
Subject: Re: kernel BUG at net/ipv4/tcp_output.c:1006!
Date: Fri, 13 May 2011 16:01:38 -0400 (EDT)
Message-ID: <20110513.160138.1477780250019480052.davem@davemloft.net>
References: <1305307633.3866.61.camel@edumazet-laptop>
	<4DCD86C0.9030904@techboom.com>
	<1305316058.3120.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lkml@techboom.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305316058.3120.6.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 13 May 2011 21:47:38 +0200

> I suspect we should push commit 2fceec13375e5d98 (tcp: len check is
> unnecessarily devastating, change to WARN_ON) to stable if not already
> done...
> 
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=2fceec13375e5d98
> 
> David, is this commit in your stable queue ?

No, but now it is.
