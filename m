From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] percpu: add optimized generic percpu accessors
Date: Wed, 28 Jan 2009 17:12:40 +0900
Message-ID: <49801378.6060407@gmail.com>
References: <20090115183942.GA6325@elte.hu> <200901201328.24605.rusty@rustcorp.com.au> <49756E6E.2060409@kernel.org> <200901271213.18605.rusty@rustcorp.com.au> <497E705B.5000302@kernel.org> <20090127131317.GF23121@elte.hu> <497F93A2.404@kernel.org> <497FD2AF.6020801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	akpm@linux-foundation.org, hpa@zytor.com, brgerst@gmail.com,
	ebiederm@xmission.com, cl@linux-foundation.org, travis@sgi.com,
	linux-kernel@vger.kernel.org, steiner@sgi.com, hugh@veritas.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.229]:46893 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752621AbZA1IM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 03:12:57 -0500
In-Reply-To: <497FD2AF.6020801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tejun Heo wrote:
> Okay, rebased on top of the current master[1].
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git tj-percpu
> 
> The rebased commit ID is e7f538f3d2a6b3a0a632190a7d736730ee10909c.
> 
> There were several changes which didn't fit the rebased tree as they
> really belong to other branches in the x86 tree.  I'll re-submit them
> as patches against the appropriate branch.

Two patches against #stackprotector and one against #cpus4096 sent
out.  With these three patches, most of stuff has been preserved but
there are still few missing pieces which only make sense after trees
are merged.  Will be happy to drive it if the current branch looks
fine.

Thanks.

-- 
tejun
