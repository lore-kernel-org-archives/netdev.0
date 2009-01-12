From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: nfs client lockdep warning
Date: Mon, 12 Jan 2009 13:10:39 +0100
Message-ID: <20090112121039.GA27332@elte.hu>
References: <20090108203658.GE19312@fieldses.org> <1231447707.7179.10.camel@heimdal.trondhjem.org> <20090108212056.GF19312@fieldses.org> <20090109043315.GA12139@gondor.apana.org.au> <1231480697.11687.522.camel@twins> <20090109062333.GB13304@gondor.apana.org.au> <1231483868.11687.523.camel@twins> <20090109202939.GA5466@fieldses.org> <1231761731.4371.7.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Trond Myklebust <trond-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Nick Piggin <npiggin-l3A5Bk7waGM@public.gmane.org>
To: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1231761731.4371.7.camel@laptop>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


* Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org> wrote:

> Subject: lockdep,mm: fix might_fault() annotation
> 
> Some code (nfs/sunrpc) uses socket ops on kernel memory while holding
> the mmap_sem, this is safe because kernel memory doesn't get paged out,
> therefore we'll never actually fault, and the might_fault() annotations
> will generate false positives.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>

applied to tip/core/urgent, thanks guys!

I also added a:

 Reported-by: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>

line as we always want to preserve the chain of bug reports and attribute 
them.

	Ingo
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
