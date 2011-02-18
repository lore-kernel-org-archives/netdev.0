From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: dont leave active on stack LIST_HEAD
Date: Fri, 18 Feb 2011 12:14:24 -0800 (PST)
Message-ID: <20110218.121424.112608933.davem@davemloft.net>
References: <1298010320.2642.7.camel@edumazet-laptop>
	<1298014191.2642.11.camel@edumazet-laptop>
	<1298019278.2595.83.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, ebiederm@xmission.com,
 opurdila@ixiacom.com, mingo@elte.hu, mhocko@suse.cz, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1298019278.2595.83.camel@edumazet-laptop>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 Feb 2011 09:54:38 +0100

> From: Linus Torvalds <torvalds@linux-foundation.org>
> 
> Eric W. Biderman and Michal Hocko reported various memory corruptions
> that we suspected to be related to a LIST head located on stack, that
> was manipulated after thread left function frame (and eventually exited,
> so its stack was freed and reused).
> 
> Eric Dumazet suggested the problem was probably coming from commit
> 443457242beb (net: factorize
> sync-rcu call in unregister_netdevice_many)
> 
> This patch fixes __dev_close() and dev_close() to properly deinit their
> respective LIST_HEAD(single) before exiting.
> 
> References: https://lkml.org/lkml/2011/2/16/304
> References: https://lkml.org/lkml/2011/2/14/223
> 
> Reported-by: Michal Hocko <mhocko@suse.cz>
> Reported-by: Eric W. Biderman <ebiderman@xmission.com>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
