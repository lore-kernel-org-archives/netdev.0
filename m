From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] mm: make page pfmemalloc check more robust
Date: Thu, 13 Aug 2015 07:40:56 -0700
Message-ID: <1439476856.7960.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439456364-4530-1-git-send-email-mhocko@kernel.org>
	 <55CC5FA0.300@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mhocko@kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>,
 Jiri Bohac <jbohac@suse.cz>, Andrew Morton <akpm@linux-foundation.org>,
 "David S. Miller" <davem@davemloft.net>, LKML
 <linux-kernel@vger.kernel.org>,  netdev@vger.kernel.org, Michal Hocko
 <mhocko@suse.com>
To: Vlastimil Babka <vbabka@suse.cz>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <55CC5FA0.300@suse.cz>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-08-13 at 11:13 +0200, Vlastimil Babka wrote:

> Given that this apparently isn't the first case of this localhost issue, 
> I wonder if network code should just clear skb->pfmemalloc during send 
> (or maybe just send over localhost). That would be probably easier than 
> distinguish the __skb_fill_page_desc() callers for send vs receive.

Would this still needed after this patch ?

It is sad we do not have a SNMP counter to at least count how often we
drop skb because pfmemalloc is set.

I'll provide such a patch.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
