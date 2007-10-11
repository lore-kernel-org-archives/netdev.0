From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] rtnl: Simplify ASSERT_RTNL
Date: Thu, 11 Oct 2007 10:33:39 -0600
Message-ID: <m1tzoxehlo.fsf@ebiederm.dsl.xmission.com>
References: <m1r6ki9tib.fsf@ebiederm.dsl.xmission.com>
	<20071010.211654.85404234.davem@davemloft.net>
	<m1r6k2i1es.fsf@ebiederm.dsl.xmission.com>
	<20071011071224.GA15860@gondor.apana.org.au>
	<m1hckyf4ag.fsf@ebiederm.dsl.xmission.com>
	<20071011082845.GA16527@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:50053 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbXJKQfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 12:35:06 -0400
In-Reply-To: <20071011082845.GA16527@gondor.apana.org.au> (Herbert Xu's
	message of "Thu, 11 Oct 2007 16:28:45 +0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> writes:

> Well thanks to that warning we're on our way of improving the
> code that triggered it in such a way that this warning will soon
> go silent.
>
> That's precisely the reason why I object to having this warning
> removed.  Now you have a good point that this warning doesn't
> trigger all the time.  The fix to that is to *make* it trigger
> always, not removing it.

I'm almost convinced but.

Where people deliberately use convoluted locking is where we
most need things like ASSERT_RTNL.

Having ASSERT_RTNL warn if you were sleeping does not seem
intuitive from the name.

This instance of convoluted locking seems like a complete
one off to me, and if it will warn about other constructs
currently in the kernel it seems wrong.

Frankly I don't feel comfortable adding the check because I can't
defend the presence of might_sleep() in ASSERT_RTNL.  If I can't
understand a change well enough to defend it I will not take
responsibility for it, and I will not add my Signed-off-by to it.

The patch I wrote was trivial a trivial optimization and obviously
correct.  Adding the might_sleep() and the patch becomes the start
of a crusade for better code that I don't believe in.

So I would rather forget this patch then make that one line addition.

Thanks,
Eric



