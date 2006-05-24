From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 6610] New: dummy interface broadcast destination hardware address is not ff:ff:ff:ff:ff:ff
Date: Wed, 24 May 2006 11:10:54 +1000
Message-ID: <E1Fihtm-0003dO-00@gondolin.me.apana.org.au>
References: <20060523.165343.104035136.davem@davemloft.net>
Cc: akpm@osdl.org, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:64782 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932512AbWEXBLL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 May 2006 21:11:11 -0400
To: davem@davemloft.net (David Miller)
In-Reply-To: <20060523.165343.104035136.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> From: Andrew Morton <akpm@osdl.org>
> Date: Tue, 23 May 2006 16:31:42 -0700
> 
>> >            Summary: dummy interface broadcast destination hardware address
>> >                     is not ff:ff:ff:ff:ff:ff
> 
> Very strange because the dummy device driver calls
> ether_setup() which does:

It's caused by the NO_ARP flag.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
