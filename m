From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUG] INFO: inconsistent lock state
Date: Wed, 7 Jan 2009 23:16:54 +1100
Message-ID: <20090107121654.GA25591@gondor.apana.org.au>
References: <4962C322.8000201@cn.fujitsu.com> <49633005.5080305@redhat.com> <4963319D.8040204@cn.fujitsu.com> <496350DF.5030500@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Li Zefan <lizf@cn.fujitsu.com>, David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Zdenek Kabelac <zkabelac@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33658 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751811AbZAGMRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 07:17:01 -0500
Content-Disposition: inline
In-Reply-To: <496350DF.5030500@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 06, 2009 at 12:38:55PM +0000, Zdenek Kabelac wrote:
>
> I've just tested the very latest build from git repository:
> (commit: 238c6d54830c624f34ac9cf123ac04aebfca5013)

You also need

commit ea319518ba3de282c13ae1cf4bf2215c5e03e67e
Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date:   Fri Dec 26 15:08:55 2008 +0100

    locking, percpu counters: introduce separate lock classes
    
    Impact: fix lockdep false positives
    
    Classify percpu_counter instances similar to regular lock objects --
    that is, per instantiation site.
    
    The networking code has increased its use of percpu_counters, which
    leads to false positives if they are treated as a single class.
    
    Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
