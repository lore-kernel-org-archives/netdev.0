From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] rtnl: Simplify ASSERT_RTNL
Date: Sun, 30 Sep 2007 08:28:33 +0800
Message-ID: <20070930002833.GA7669@gondor.apana.org.au>
References: <E1IbTz0-0000FK-00@gondolin.me.apana.org.au> <m13awx8k6d.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3902 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752827AbXI3A2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 20:28:39 -0400
Content-Disposition: inline
In-Reply-To: <m13awx8k6d.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 29, 2007 at 11:18:18AM -0600, Eric W. Biederman wrote:
>
> Regardless of the correctness of where we have ASSERT_RTNL.
> I think not actually taking the mutex on the assertion failure path
> (just so we can release it), is still a good deal regardless.

Provided that you add a might_sleep call in there so that if
somebody does this under locks it'll complain then I agree.

Checking RTNL under spin locks is almost certainly the sign
of a bug.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
