From: David Miller <davem@davemloft.net>
Subject: Re: [0/3] bridge: Do not send multicast queries by default
Date: Sun, 15 Apr 2012 12:50:23 -0400 (EDT)
Message-ID: <20120415.125023.1717763086421927975.davem@davemloft.net>
References: <20120413123641.GA758@gondor.apana.org.au>
	<20120413.105345.319552552748408545.davem@davemloft.net>
	<20120415111300.GA14147@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.hengli.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37362 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755648Ab2DOQwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Apr 2012 12:52:25 -0400
In-Reply-To: <20120415111300.GA14147@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Sun, 15 Apr 2012 19:13:00 +0800

> However, we're not implementing an RFC2710 node here.  What we're
> doing is better described by RFC4541 (IGMP/MLD snooping), which calls
> for the use of a zero source address for both IPv4 and IPv6.
> 
> The reason is precisely because it's invalid for normal querier
> nodes and as such they would ignore us (rather than elect us
> and potentially disrupt things).

Ok, make sense.

And in fact, I welcome changing this back to using a zero saddr, as
the ipv6 source address setting code brought in a lot of ugly
dependencies. :-)
