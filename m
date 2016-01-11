From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next 1/5] sctp: add the rhashtable apis for sctp
 global transport hashtable
Date: Mon, 11 Jan 2016 17:32:10 +0800
Message-ID: <20160111093210.GA23557@gondor.apana.org.au>
References: <20151230.125046.310343849422003518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, lucien.xin@gmail.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	mleitner@redhat.com, vyasevic@redhat.com, daniel@iogearbox.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:48888 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757777AbcAKJcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 04:32:15 -0500
Content-Disposition: inline
In-Reply-To: <20151230.125046.310343849422003518.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 30 Dec 2015 11:57:31 -0500
> 
>> I am against using rhashtable in SCTP (or TCP) at this stage, given the
>> number of bugs we have with it.
> 
> Come on Eric, we've largely dealt with all of these problems.  I haven't
> seen a serious report in a while.

Well there is still the outstanding issue with softirq insertion
potentially failing with ENOMEM if we fail to expand the hash
table using just kmalloc.

So if the target user does softirq insertions, I would wait until
the fix for that is ready.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
