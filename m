From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default
	configurable
Date: Thu, 2 Jul 2009 00:26:11 +0800
Message-ID: <20090701162611.GA5451@gondor.apana.org.au>
References: <1246379267.3749.42.camel@blaa> <20090630.201630.134200035.davem@davemloft.net> <1246445158.598.30.camel@blaa> <20090701.090202.247626454.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: markmc@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38917 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753309AbZGAQ0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 12:26:11 -0400
Content-Disposition: inline
In-Reply-To: <20090701.090202.247626454.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 01, 2009 at 09:02:02AM -0700, David Miller wrote:
> 
> Consider the posibility that the people using it aren't saying
> anything because things just-work for them right now.
> 
> If you change this default, I guarentee we will hear from them.
> 
> "everyone else" is making noise only because the default isn't
> what they want.  There is no other reason.

FWIW I don't really care what we have as the default for bridge
netfilter.  I just want to make sure that people who do have
bridge netfilter (and in particular, conntrack + bridge) active
on their machines are aware of the security implications.  Otherwise
we'd be negligent.

As you said distros can change the default regardless of what
the kernel does.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
