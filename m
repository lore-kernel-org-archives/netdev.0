From: David Miller <davem@davemloft.net>
Subject: Re: 3.8-rc2/rc3 write() blocked on CLOSE_WAIT TCP socket
Date: Thu, 10 Jan 2013 22:49:54 -0800 (PST)
Message-ID: <20130110.224954.902891494419623809.davem@davemloft.net>
References: <20130111004915.GA15415@dcvr.yhbt.net>
	<1357869675.27446.2962.camel@edumazet-glaptop>
	<1357870727.27446.2988.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: normalperson@yhbt.net, netdev@vger.kernel.org, mgorman@suse.de,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@redhat.com,
 minchan@kernel.org, akpm@linux-foundation.org,
 torvalds@linux-foundation.org
To: eric.dumazet@gmail.com
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1357870727.27446.2988.camel@edumazet-glaptop>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 10 Jan 2013 18:18:47 -0800

> [PATCH] tcp: accept RST without ACK flag
> 
> commit c3ae62af8e755 (tcp: should drop incoming frames without ACK flag
> set) added a regression on the handling of RST messages.
> 
> RST should be allowed to come even without ACK bit set. We validate
> the RST by checking the exact sequence, as requested by RFC 793 and 
> 5961 3.2, in tcp_validate_incoming()
> 
> Reported-by: Eric Wong <normalperson@yhbt.net>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
