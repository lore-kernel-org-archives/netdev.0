From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] [IPV6]: Multiple Routing Tables
Date: Mon, 31 Jul 2006 13:09:50 -0700 (PDT)
Message-ID: <20060731.130950.125895376.davem@davemloft.net>
References: <44CE0BE6.1070108@tcs.hut.fi>
	<E1G7YKN-0007Ao-00@gondolin.me.apana.org.au>
	<20060731154142.GK14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:55992
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932477AbWGaUJx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 16:09:53 -0400
To: tgraf@suug.ch
In-Reply-To: <20060731154142.GK14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Mon, 31 Jul 2006 17:41:42 +0200

> * Herbert Xu <herbert@gondor.apana.org.au> 2006-08-01 00:01
> > Actually, if we're adding policy routing, we should seriously consider
> > whether living without a routing cache is still viable or not because
> > the cost of a route lookup has just gone up.
> 
> Absolutely.

This is something I wanted to bring up too.
