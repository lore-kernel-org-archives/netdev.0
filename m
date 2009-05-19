From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use NLMSG_DEFAULT_SIZE in nlmsg_new() allocations
Date: Tue, 19 May 2009 15:28:07 -0700 (PDT)
Message-ID: <20090519.152807.141633274.davem@davemloft.net>
References: <20090519155820.27716.47419.stgit@Decadence>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samuel@sortiz.org,
	johannes@sipsolutions.net
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49868
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755253AbZESW2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 18:28:09 -0400
In-Reply-To: <20090519155820.27716.47419.stgit@Decadence>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 19 May 2009 17:58:20 +0200

> nlmsg_new() adds the size of the netlink header to the value
> that has been passed as parameter. If NLMSG_GOODSIZE is selected,
> we request an allocation of one memory page plus the size of the
> header. Instead, NLMSG_DEFAULT_SIZE should be used since it
> already substracts the size of the Netlink header.
> 
> I have the impression that the similar naming in both constant
> is error prone when using it with nlmsg_new(). This is already
> documented in include/net/netlink.h
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Looks good, applied to net-next-2.6, thanks!
