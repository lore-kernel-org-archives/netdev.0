From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: [PATCH 03/31] mm: expose gfp_to_alloc_flags()
Date: Fri, 02 Oct 2009 13:41:10 +0530
Message-ID: <4AC5B59E.3050608@suse.de>
References: <1254405903-15760-1-git-send-email-sjayaraman@suse.de> <alpine.DEB.1.00.0910011355230.32006@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, Neil Brown <neilb@suse.de>,
	Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no
To: David Rientjes <rientjes@google.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <alpine.DEB.1.00.0910011355230.32006@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

David Rientjes wrote:
> On Thu, 1 Oct 2009, Suresh Jayaraman wrote:
> 
>> From: Peter Zijlstra <a.p.zijlstra@chello.nl> 
>>
>> Expose the gfp to alloc_flags mapping, so we can use it in other parts
>> of the vm.
>>
>> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
>> Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
> 
> Nack, these flags are internal to the page allocator and exporting them to 
> generic VM code is unnecessary.

Yes, you're right.

> The only bit you actually use in your patchset is ALLOC_NO_WATERMARKS to 
> determine whether a particular allocation can use memory reserves.  I'd 
> suggest adding a bool function that returns whether the current context is 
> given access to reserves including your new __GFP_MEMALLOC flag and 
> exporting that instead.

Makes sense and Neil already posted a patch citing the suggested
changes, will incorporate the change.

Thanks,

-- 
Suresh Jayaraman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
