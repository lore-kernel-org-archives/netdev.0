From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: use non-BH variant of RCU
Date: Sat, 14 Aug 2010 23:50:33 -0700 (PDT)
Message-ID: <20100814.235033.02286546.davem@davemloft.net>
References: <20100813143904.GA27261@gondor.apana.org.au>
	<20100813162912.GJ2511@linux.vnet.ibm.com>
	<20100813175157.GA29586@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, linville@tuxdriver.com,
	netdev@vger.kernel.org, mingo@elte.hu, linux-kernel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45678
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754590Ab0HOGuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Aug 2010 02:50:16 -0400
In-Reply-To: <20100813175157.GA29586@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 13 Aug 2010 13:51:57 -0400

> On Fri, Aug 13, 2010 at 09:29:12AM -0700, Paul E. McKenney wrote:
>> But all in all, mightn't it be easier to remove the checks from
>> _local_bh_enable(), and then just use rcu_read_lock_bh()?  Have those
>> checks really been that helpful in finding bugs?  ;-)
> 
> You are right.  It would be much simpler to simply have it not
> warn.

For now I'm going to assume that this is how the issue will be
addressed.
