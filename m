From: David Miller <davem@davemloft.net>
Subject: Re: Deadlock with icmpv6fuzz
Date: Sun, 08 Feb 2009 22:04:55 -0800 (PST)
Message-ID: <20090208.220455.146957669.davem@davemloft.net>
References: <20090206.030716.136181382.davem@davemloft.net>
	<20090209050354.GA3548@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, snakebyte@gmx.de, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55586
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753040AbZBIGFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 01:05:02 -0500
In-Reply-To: <20090209050354.GA3548@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 9 Feb 2009 16:03:54 +1100

> In fact, a number of spots in IPv6 already use sock_kmalloc
> for these objects anyway (e.g., ipv6_dup_options in exthdrs.c)
> so there is no fundamental reason why this limit can't be imposed.

Indeed, we are consistently inconsistent here.
