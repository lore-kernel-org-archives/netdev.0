From: Stephan Mueller <smueller@chronox.de>
Subject: Re: [v2 PATCH 13/13] crypto: algif_aead - Switch to new AEAD interface
Date: Fri, 22 May 2015 23:04:39 +0200
Message-ID: <13023896.hEcYqcIc2j@myon.chronox.de>
References: <20150522082708.GA3507@gondor.apana.org.au> <E1YviMC-00010E-Uk@gondolin.me.apana.org.au> <1711949.C5mmxUsD4a@myon.chronox.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.eperm.de ([89.247.134.16]:58192 "EHLO mail.eperm.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757717AbbEVVEl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2015 17:04:41 -0400
In-Reply-To: <1711949.C5mmxUsD4a@myon.chronox.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 22. Mai 2015, 22:59:34 schrieb Stephan Mueller:

Hi Stephan,

> Am Freitag, 22. Mai 2015, 16:31:04 schrieb Herbert Xu:
> 
> Hi Herbert,
> 
> > This patch makes use of the new AEAD interface which uses a single
> > SG list instead of separate lists for the AD and plain text.
> 
> Using an up-to date tree with the full set of patches of this patch set, I
> get the following oops.
> 
> It can easily be reproduced by using [1]: go to libkcapi/test/ and compile
> with make. Then execute ./test.sh
> 
> [1] http://www.chronox.de/libkcapi.html

Note, gcm(aes) looks good. Only rfc4106(gcm(aes)) causes the crash.

-- 
Ciao
Stephan
