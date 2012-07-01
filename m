From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] bonding support for IPv6 transmit hashing
Date: Sun, 01 Jul 2012 03:33:54 -0700 (PDT)
Message-ID: <20120701.033354.539821533277159165.davem@davemloft.net>
References: <cover.1341125875.git.linux@8192.net>
	<c390ff662ede0f304398a88ca1a96e3773065c60.1341129744.git.linux@8192.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux@8192.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755042Ab2GAKdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 06:33:54 -0400
In-Reply-To: <c390ff662ede0f304398a88ca1a96e3773065c60.1341129744.git.linux@8192.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Eaglesham <linux@8192.net>
Date: Sun,  1 Jul 2012 01:07:43 -0700

> +		v6hash =
> +			(ipv6h->saddr.s6_addr32[1] ^ ipv6h->daddr.s6_addr32[1]) ^
> +			(ipv6h->saddr.s6_addr32[2] ^ ipv6h->daddr.s6_addr32[2]) ^
> +			(ipv6h->saddr.s6_addr32[3] ^ ipv6h->daddr.s6_addr32[3]);

You completely ignored my feedback:

	This is rediculous, just put &ipv6h->saddr into a local
	pointer named 's' and then you won't have use such gymnastics
	to indent the code.
