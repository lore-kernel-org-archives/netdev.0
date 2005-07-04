From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [TG3]: About hw coalescing infrastructure.
Date: Mon, 04 Jul 2005 15:47:12 -0700 (PDT)
Message-ID: <20050704.154712.63128211.davem@davemloft.net>
References: <20050704.142604.18592223.davem@davemloft.net>
	<42C9AC97.1020902@cosmosbay.com>
	<42C9B8DB.7020403@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dada1@cosmosbay.com
In-Reply-To: <42C9B8DB.7020403@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 05 Jul 2005 00:31:55 +0200

> Oops, I forgot to tell you I applied the patch  : [TG3]: Eliminate all hw IRQ handler spinlocks.
> (Date: Fri, 03 Jun 2005 12:25:58 -0700 (PDT))
> 
> Maybe I should revert to stock 2.6.12 tg3 driver ?

Please don't ever do stuff like that :-(  That makes the driver
version, and any other information you report completely meaningless
and useless.  You've just wasted a lot of our time.

I have no idea to even know _WHICH_ IRQ spinlock patch you applied.

The one that ended up in Linus's tree has many bug fixes and
refinements.  The ones which were posted on netdev had many bugs and
deadlocks which needed to be cured before pushing the change upstream.
