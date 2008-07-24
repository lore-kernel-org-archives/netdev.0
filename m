From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC][PATCH 1/3] net: per skb control messages
Date: Fri, 25 Jul 2008 00:49:46 +0300
Message-ID: <200807250049.46939.opurdila@ixiacom.com>
References: <200807241634.31614.opurdila@ixiacom.com> <200807241922.57361.opurdila@ixiacom.com> <20080724.132821.212118602.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:2846 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750744AbYGXVwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 17:52:14 -0400
In-Reply-To: <20080724.132821.212118602.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 24 July 2008, David Miller wrote:

> Adding new fields to struct sk_buff that take up space is generally
> not allowed unless the new field adds substantially to the benefit of
> a large group of users of Linus.
>
> I don't think that applied here for this hw-tstamps stuff.

What about the approach proposed in the patch? Is it ok to add a pointer which 
may resolve other future similar issues?

Thanks,
tavi
