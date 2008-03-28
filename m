From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Fri, 28 Mar 2008 21:26:43 +0800
Message-ID: <20080328132643.GA24180@gondor.apana.org.au>
References: <47EC399E.90804@sun.com> <20080327.173418.18777696.davem@davemloft.net> <20080328012234.GA20465@gondor.apana.org.au> <20080327.183844.74572930.davem@davemloft.net> <20080328102931.GA23039@gondor.apana.org.au> <20080328105629.GG1011@elte.hu> <20080328110621.GA23342@gondor.apana.org.au> <20080328112928.GA23547@gondor.apana.org.au> <1206706759.4429.58.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>, Matheos.Worku@Sun.COM,
	jesse.brandeburg@intel.com, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33751 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752386AbYC1N1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 09:27:01 -0400
Content-Disposition: inline
In-Reply-To: <1206706759.4429.58.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2008 at 08:19:19AM -0400, jamal wrote:
>
> **** heres something that has not yet resolved in my mind (even for the
> NAPI case which was inherited from code that has been there forever).
> Theres probably a very simple answer ;->
> say we have two machines:
> one faster and we decide HZ = 1000 meaning 1ms for a jiffy; the other
> slower and we make HZ 100 i.e 10ms jiffy.
> Logically, shouldnt the slower machine allocate less time running the
> loop since it has less resources? in the above case it would spend 10
> times more. 

I agree that using jiffies is a pretty coarse approximation of
proper scheduling.  However, in the absence of a better solution
we have to live with it.

Perhaps running these out of process context is the correct
approach.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
