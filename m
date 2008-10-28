From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6v2] netfilter: replace uses of NIP6_FMT with %p6
Date: Tue, 28 Oct 2008 16:08:37 -0700 (PDT)
Message-ID: <20081028.160837.116477756.davem@davemloft.net>
References: <1225223641.11483.42.camel@brick>
	<1225224815.11483.56.camel@brick>
	<1225233757.5269.211.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: harvey.harrison@gmail.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38515
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753256AbYJ1XI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 19:08:59 -0400
In-Reply-To: <1225233757.5269.211.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 28 Oct 2008 15:42:36 -0700

> I think it's better to change all uses of:
>   (foo.<ie: ct->tuplehash[dir].tuple.src.>)u3.ip6
> to:
>   &foo.u3.in6
> 
> as the union defines a struct in6_addr and not use the
> ip6 array which is __be32[4].

Someone can feel free to submit this as a follow-on patch :)
