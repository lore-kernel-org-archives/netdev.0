From: Rik van Riel <riel@redhat.com>
Subject: Re: split-lru performance mesurement part2
Date: Tue, 07 Oct 2008 17:28:09 -0400
Message-ID: <48EBD469.6090409@redhat.com>
References: <20081003153810.5dd0a33e@bree.surriel.com>	<20081004232549.CE53.KOSAKI.MOTOHIRO@jp.fujitsu.com>	<20081007231851.3B88.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081007131719.8bb24698.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,
	Lee.Schermerhorn@hp.com, a.p.zijlstra@chello.nl,
	torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org,
	trond.myklebust@fys.uio.no, dlezcano@fr.ibm.com,
	penberg@cs.helsinki.fi, neilb@suse.de, davem@davemloft.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20081007131719.8bb24698.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:

> dbench is pretty chaotic and it could be that a good change causes
> dbench to get worse.  That's happened plenty of times in the past.
> 
> 
>> Do you have any suggestion?
> 
> 
> One of these:
> 
> vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-lru.patch
> vm-dont-run-touch_buffer-during-buffercache-lookups.patch
> 
> perhaps?

Worth a try, but it could just as well be a CPU scheduler change
that happens to indirectly impact locking :)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
