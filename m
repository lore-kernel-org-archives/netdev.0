From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH v2 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Wed, 06 Apr 2016 11:43:39 -0400 (EDT)
Message-ID: <20160406.114339.1083222124758102992.davem@davemloft.net>
References: <20160405.194517.431351466693438399.davem@davemloft.net>
	<5704F156.8030804@solarflare.com>
	<CALx6S34Sqp7tnmkPRWH0RF_CKrBLLNWFjHbr6Uq2r=6=scMMow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ecree@solarflare.com, herbert@gondor.apana.org.au,
	alexander.duyck@gmail.com, aduyck@mirantis.com, jesse@kernel.org,
	edumazet@google.com, netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42619 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753049AbcDFPnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 11:43:42 -0400
In-Reply-To: <CALx6S34Sqp7tnmkPRWH0RF_CKrBLLNWFjHbr6Uq2r=6=scMMow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 6 Apr 2016 10:53:52 -0300

> Packets that are forwarded really should not be GRO'ed in the first
> place because of the loss of information and added latency.

First of all GRO is supposed to be lossless, so please stop saying this
would be a reason to turn it off on a router.

Second of all, the biggest piece of overhead is the routing lookup,
therefore GRO batching helps enormously with routing workloads, and
therefore is appropriate to be enabled on routers.

Yes, I agree that for locally terminated stuff it helps more, but don't
turn this into a "GRO on routers, meh..." type argument.  It simply is
not true at all.
