From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to use rtnl_notify()
Date: Tue, 15 Aug 2006 10:56:43 +1000
Message-ID: <E1GCnEZ-0006XU-00@gondolin.me.apana.org.au>
References: <20060815003614.GA8677@ms2.inr.ac.ru>
Cc: hadi@cyberus.ca, tgraf@suug.ch, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:20742 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965039AbWHOA5j
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 20:57:39 -0400
To: kuznet@ms2.inr.ac.ru (Alexey Kuznetsov)
In-Reply-To: <20060815003614.GA8677@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:
> 
>> IMO, I believe there is a strong case that can be made for events that
>> were caused by non-netlink users such as ioctls that could at least be
>> multicast with current->pid.
> 
> Highly not desired.

Agreed.  The pid field in the netlink header should be treated as an
opaque value.  Any attempt to interpret it as the process ID is doomed
to failure.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
