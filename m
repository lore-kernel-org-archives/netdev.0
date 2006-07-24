From: David Miller <davem@davemloft.net>
Subject: Re: What is RDMA
Date: Mon, 24 Jul 2006 15:29:25 -0700 (PDT)
Message-ID: <20060724.152925.85821176.davem@davemloft.net>
References: <1152163503.20248.98.camel@trinity.ogc.int>
	<20060706.235320.92562667.davem@davemloft.net>
	<20060707081131.GA2991@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@opengridcomputing.com, rdreier@cisco.com,
	netdev@vger.kernel.org, akpm@osdl.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19597
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932296AbWGXW3P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 18:29:15 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060707081131.GA2991@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 7 Jul 2006 18:11:31 +1000

> 5) RDMA over TCP on the receive side is offloaded into the NIC.  This
>    allows the NIC to directly place data into the application's buffer.  
> 
>    We're starting to have a little bit of a problem because it means that
>    part of the incoming IP traffic is now being directly processed by the
>    NIC, with no input from the Linux TCP/IP stack.
> 
>    However, as long as the connection establishment/acks are still
>    controlled/seen by Linux we can probably live with it.

As I have detailed in other emails, even if you get the connection
establishment packets processed by netfilter, you can end up with
a non-working connection because NAT can want to transform all of
the established state packets in the same way.
