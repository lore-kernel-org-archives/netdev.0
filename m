From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] rtnl: Simplify ASSERT_RTNL
Date: Sat, 29 Sep 2007 19:51:18 +0200
Message-ID: <46FE9096.1030807@trash.net>
References: <E1IbTz0-0000FK-00@gondolin.me.apana.org.au> <m13awx8k6d.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53165 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754338AbXI2Rvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 13:51:41 -0400
In-Reply-To: <m13awx8k6d.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Regardless of the correctness of where we have ASSERT_RTNL.
> I think not actually taking the mutex on the assertion failure path
> (just so we can release it), is still a good deal regardless.


Agreed. I actually have an identical patch somewhere that
I wanted to submit soon.


