From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 05/10] headers, net: Define struct
 __kernel_sockaddr, replacing struct sockaddr
Date: Fri, 26 Aug 2011 12:04:51 -0400 (EDT)
Message-ID: <20110826.120451.1765083060493659307.davem@davemloft.net>
References: <1314247456.27179.122.camel@deadeye>
	<20110826.110820.2220935212459386472.davem@davemloft.net>
	<20110826154248.GD24107@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56437 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754352Ab1HZQE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 12:04:59 -0400
In-Reply-To: <20110826154248.GD24107@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 26 Aug 2011 16:42:48 +0100

> This #define is in the #ifdef __KERNEL__ section.  I don't want t
> change all the in-kernel users to say __kernel_sockaddr.  This is
> just the same as the preceding 'typedef __kernel_sa_family_t
> sa_family_t' except that you can't create struct aliases that way.

Aha, I didn't catch that part.  Then this is fine, thanks for
explaining Ben.
