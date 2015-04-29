From: David Miller <davem@davemloft.net>
Subject: Re: [bisected] ICMP fragmentation needed ignored / PMTU discovery
 broken since 3.19-rc7
Date: Wed, 29 Apr 2015 14:43:52 -0400 (EDT)
Message-ID: <20150429.144352.361536645438114802.davem@davemloft.net>
References: <1508242.C2rIQlqbSL@thunder>
	<20150428034314.GA30299@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerd.von.egidy@intra2net.com, netdev@vger.kernel.org,
	lw@cn.fujitsu.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50007 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964AbbD2Sn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 14:43:57 -0400
In-Reply-To: <20150428034314.GA30299@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 28 Apr 2015 11:43:15 +0800

> Subject: route: Use ipv4_mtu instead of raw rt_pmtu
> 
> The commit 3cdaa5be9e81a914e633a6be7b7d2ef75b528562 ("ipv4: Don't
> increase PMTU with Datagram Too Big message") broke PMTU in cases
> where the rt_pmtu value has expired but is smaller than the new
> PMTU value.
> 
> This obsolete rt_pmtu then prevents the new PMTU value from being
> installed.
> 
> Fixes: 3cdaa5be9e81 ("ipv4: Don't increase PMTU with Datagram Too Big message")
> Reported-by: Gerd v. Egidy <gerd.von.egidy@intra2net.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and queued up for -stable, thanks!
