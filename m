From: David Miller <davem@davemloft.net>
Subject: Re: [IPV6]: Audit all ip6_dst_lookup/ip6_dst_store calls
Date: Sun, 30 Jul 2006 15:44:16 -0700 (PDT)
Message-ID: <20060730.154416.121293840.davem@davemloft.net>
References: <20060728194531.GA17744@lists.us.dell.com>
	<20060729043325.GA7035@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, Matt_Domsch@dell.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:49285
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751428AbWG3WoH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 18:44:07 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060729043325.GA7035@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 29 Jul 2006 14:33:25 +1000

> [IPV6]: Audit all ip6_dst_lookup/ip6_dst_store calls
> 
> The current users of ip6_dst_lookup can be divided into two classes:
> 
> 1) The caller holds no locks and is in user-context (UDP).
> 2) The caller does not want to lookup the dst cache at all.
> 
> The second class covers everyone except UDP because most people do
> the cache lookup directly before calling ip6_dst_lookup.  This patch
> adds ip6_sk_dst_lookup for the first class.
> 
> Similarly ip6_dst_store users can be divded into those that need to
> take the socket dst lock and those that don't.  This patch adds
> __ip6_dst_store for those (everyone except UDP/datagram) that don't
> need an extra lock.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
