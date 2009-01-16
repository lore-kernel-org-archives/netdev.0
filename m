From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] percpu: add optimized generic percpu accessors
Date: Fri, 16 Jan 2009 11:18:24 +1100
Message-ID: <20090116001824.GA9221@gondor.apana.org.au>
References: <20090115183942.GA6325@elte.hu> <20090116001200.GA9137@gondor.apana.org.au> <20090116001544.GA11073@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, tj@kernel.org, hpa@zytor.com,
	brgerst@gmail.com, ebiederm@xmission.com, cl@linux-foundation.org,
	rusty@rustcorp.com.au, travis@sgi.com,
	linux-kernel@vger.kernel.org, steiner@sgi.com, hugh@veritas.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37142 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752449AbZAPAS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 19:18:58 -0500
Content-Disposition: inline
In-Reply-To: <20090116001544.GA11073@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 16, 2009 at 01:15:44AM +0100, Ingo Molnar wrote:
>
> > So if you could design the API such that we have a variant of add/inc 
> > that automatically disables/enables preemption then we can optimise that 
> > away on x86.
> 
> Yeah. percpu_add(var, 1) does exactly that on x86.

Awesome! Sounds like we can finally do away with those nasty
hacks in the SNMP macros.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
