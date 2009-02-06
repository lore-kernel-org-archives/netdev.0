From: David Miller <davem@davemloft.net>
Subject: Re: Deadlock with icmpv6fuzz
Date: Fri, 06 Feb 2009 01:27:33 -0800 (PST)
Message-ID: <20090206.012733.06998050.davem@davemloft.net>
References: <20090206085406.GA6540@gondor.apana.org.au>
	<20090206.010559.157790037.davem@davemloft.net>
	<20090206092218.GB6645@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, snakebyte@gmx.de, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53773
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751116AbZBFJ1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 04:27:37 -0500
In-Reply-To: <20090206092218.GB6645@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 6 Feb 2009 20:22:18 +1100

> Well the data that led to the back trace came from a cmsg, I was
> merely pointing out that the cmsg itself is kmalloced and copied
> by sys_sendmsg and it's only limited to INT_MAX.

Actually, it's limited to sysctl_optmem_max :-)
