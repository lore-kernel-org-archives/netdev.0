From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [v3 PATCH 0/8] crypto: Convert all AEAD users to new interface
Date: Wed, 27 May 2015 10:15:50 +0200
Message-ID: <1432714550.2159.4.camel@sipsolutions.net>
References: <20150521103938.GA23035@gondor.apana.org.au>
	 <20150522082708.GA3507@gondor.apana.org.au>
	 <20150527080105.GA26751@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Stephan Mueller <smueller@chronox.de>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:49383 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751741AbbE0IPz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2015 04:15:55 -0400
In-Reply-To: <20150527080105.GA26751@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> The conversion of in-tree users is fairly straightforward.

It is pretty much - but a related question (that you totally don't have
to answer if you don't want to think about this).

I'm going to have to (continue) backport(ing) this code to older kernels
for customer support, and I prefer making as few modifications to the
code as possible and putting all the logic into the external backports
project.

Do you think it'd be feasible at all to somehow override the
aead_request_set_crypt() and aead_request_set_ad() functions or so to do
something that works on older kernels (and thus older crypto subsystems)
or do you think I just shouldn't bother looking at that and just add
ifdefs to "undo" your changes in this series on older kernels?

johannes
