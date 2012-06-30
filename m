From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 1/2] bonding support for IPv6 transmit hashing
Date: Sat, 30 Jun 2012 01:05:14 -0700 (PDT)
Message-ID: <20120630.010514.79398765104671796.davem@davemloft.net>
References: <4FEE99E7.9010504@8192.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux@8192.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41076 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761Ab2F3IFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2012 04:05:19 -0400
In-Reply-To: <4FEE99E7.9010504@8192.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If you're going to post multiple patches, give them unique
subject line texts describing what each change does uniquely.
Do not use identical subject lines ever, that is very unhelpful
for the people reading your changes.

From: John <linux@8192.net>
Date: Fri, 29 Jun 2012 23:17:11 -0700

> + skb_network_header_len(skb) >= sizeof(struct ipv6hdr)) {
> +		ipv6h = ipv6_hdr(skb);
> +		v6hash =
> + (ipv6h->saddr.s6_addr32[1] ^ ipv6h->daddr.s6_addr32[1]) ^
> + (ipv6h->saddr.s6_addr32[2] ^ ipv6h->daddr.s6_addr32[2]) ^
> + (ipv6h->saddr.s6_addr32[3] ^ ipv6h->daddr.s6_addr32[3]);
> +		v6hash = (v6hash >> 16) ^ (v6hash >> 8) ^ v6hash;
> + return (v6hash ^ data->h_dest[5] ^ data->h_source[5]) % count;

Either you formatted this terribly, or your email client corrupted
your patches.
