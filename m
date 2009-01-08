From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RFC: Network privilege separation.
Date: Thu, 8 Jan 2009 23:08:50 +1100
Message-ID: <20090108120850.GA3188@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: michael@laptop.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51081 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754269AbZAHMJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 07:09:03 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Stone <michael@laptop.org> wrote:
> 
> In short, I'm trying to provide a general-purpose facility for
> 
>   * limiting networking per _process_, not per user, 

You do realise that this is trivial to get around with ptrace,
right? So you'll need to stop ptrace as well.  Then you'll have
to think about all the other ways the process can escape this
networking jail because processes belonging to the same user
just aren't designed to be separated from each other.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
