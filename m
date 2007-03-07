From: David Miller <davem@davemloft.net>
Subject: Re: netlink recvmsg() and MSG_TRUNC
Date: Tue, 06 Mar 2007 16:02:02 -0800 (PST)
Message-ID: <20070306.160202.102574506.davem@davemloft.net>
References: <20070306.151953.112290310.davem@davemloft.net>
	<E1HOjP1-0003NM-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46348
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030744AbXCGACF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 19:02:05 -0500
In-Reply-To: <E1HOjP1-0003NM-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Mar 2007 10:49:07 +1100

> Which netlink family generates (or needs to generate) unbounded
> messages to user-space? Or indeed which ones generate messages
> greater than 64K (or 4K for that matter)?

Create a lot of intefaces, try to dump them :-)

GLIBC can even hit this via it's ifaddrs.c code.
