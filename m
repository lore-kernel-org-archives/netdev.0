From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Fri, 28 Jul 2006 09:56:42 +1000
Message-ID: <E1G6Fic-0005py-00@gondolin.me.apana.org.au>
References: <44C8B0B8.2010408@miyazawa.org>
Cc: yoshfuji@linux-ipv6.org, davem@davemloft.net,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3343 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750710AbWG0X5Z
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 19:57:25 -0400
To: kazunori@miyazawa.org (Kazunori Miyazawa)
In-Reply-To: <44C8B0B8.2010408@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kazunori Miyazawa <kazunori@miyazawa.org> wrote:
> 
> I'm interested in the approach. And I have a couple of comments.
> I think DAD and ND are time critical operations.
> Can the daemons process with confirming to the specs.
> even if it were swapped out?
> Can we prevent the oom killer from killing the daemons?

These are valid concerns.  However, if we can have things like ntpd
live in user-space without causing nuisance, then addrconf should be
fine as well.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
