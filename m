From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: using huge numbers of queues
Date: Fri, 9 Oct 2009 10:02:22 +0900
Message-ID: <20091009010222.GA31998@gondor.apana.org.au>
References: <c0a09e5c0910071459r2768f420lae87f7404dfbc054@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andrew Grover <andy.grover@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51923 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758155AbZJIBDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 21:03:02 -0400
Content-Disposition: inline
In-Reply-To: <c0a09e5c0910071459r2768f420lae87f7404dfbc054@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 07, 2009 at 02:59:49PM -0700, Andrew Grover wrote:
> 
> Thinking about this reminded me of VJ's 2006 netchannel concept, which
> although not adopted, was pretty interesting. Would having 1 queue per
> socket (or at least 1 per process) and hw that is able to filter
> individual flows (I think the Intel 82599 can do this now for up to
> 128) perhaps make netchannels workable? At least this would get all
> processing out of int/bh and into process context, if not userspace,
> no?

This is exactly right.  Having one socket per queue would allow
the netchannel concept to become reality without compromising
features such as netfilter.

Cheers,
--
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
