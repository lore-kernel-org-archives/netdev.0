From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] csum experts, csum_replace2() is too expensive
Date: Fri, 21 Mar 2014 20:50:35 +0800
Message-ID: <20140321125035.GA24469@gondor.apana.org.au>
References: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140321001303.GB20397@gondor.apana.org.au>
 <1395363257.9114.111.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Michael Dalton <mwdalton@google.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:41257 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755343AbaCUMuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 08:50:46 -0400
Content-Disposition: inline
In-Reply-To: <1395363257.9114.111.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 20, 2014 at 05:54:17PM -0700, Eric Dumazet wrote:
> On Fri, 2014-03-21 at 08:13 +0800, Herbert Xu wrote:
> 
> > Your patch makes sense to me.  However does it actually help
> > your 1% in the GRO profile?
> 
> Well, I caught this strange csum_partial() presence in a profile,
> but my question was more general than the GRO use case.
> 
> (BTW the patch didn't even compile ;) )
> 
> I guess that in GRO case, the following would be even faster...

Agreed.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
