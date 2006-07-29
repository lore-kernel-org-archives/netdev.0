From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] [IPV6]: Multiple Routing Tables
Date: Fri, 28 Jul 2006 21:14:28 -0700 (PDT)
Message-ID: <20060728.211428.26968121.davem@davemloft.net>
References: <20060726221100.325687073@postel.suug.ch>
	<20060726221849.495778268@postel.suug.ch>
	<20060729.131306.80352422.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:57995
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161443AbWG2EOY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jul 2006 00:14:24 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060729.131306.80352422.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Sat, 29 Jul 2006 13:13:06 +0900 (JST)

> Previously, we directly use address, ifindex etc., not flowi,
> in IPv6 routing code except for ip6_route_output().
> This patch changes them to use flowi.
> I know this should work and it is a good way for abstraction.
> However, initializing flowi for IPv6 is more expensive than
> one for IPv4, and it would result in poor performance (especially
> without CONFIG_IPV6_MULTIPLE_TABLES).
> 
> Am I too cautious?
> Should we eat this?

I think it is a legitimate consideration.

For now I would suggest we use Thomas's approach, and we
can make performance measurements to determine if it makes
to optimize this or consider other methods.
