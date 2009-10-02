From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: [PATCH 00/31] Swap over NFS -v20
Date: Fri, 02 Oct 2009 13:51:58 +0530
Message-ID: <4AC5B826.80105@suse.de>
References: <1254405858-15651-1-git-send-email-sjayaraman@suse.de> <20091001174201.GA30068@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, Neil Brown <neilb@suse.de>,
	Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no
To: Christoph Hellwig <hch@infradead.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20091001174201.GA30068@infradead.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> On Thu, Oct 01, 2009 at 07:34:18PM +0530, Suresh Jayaraman wrote:
> 
> The other really big one is adding a proper method for safe, page-backed
> kernelspace I/O on files.  That is not something like the grotty
> swap-tied address_space operations in this patch, but more something in

I'm not sure I understood about what problems you see with the proposed
address_space operations. Could you please elaborate a bit more?

> the direction of the kernel direct I/O patches from Jenx Axboe he did
> for using in the loop driver.  But even those aren't complete as they
> don't touch the locking issue yet.
> 

Thanks,

-- 
Suresh Jayaraman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
