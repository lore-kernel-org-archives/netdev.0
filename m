From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] GRE: Use IS_ERR_OR_NULL in gre_gso_segment
Date: Thu, 25 Apr 2013 05:01:57 -0400 (EDT)
Message-ID: <20130425.050157.1080837692941670798.davem@davemloft.net>
References: <20130423075042.GA25776@verge.net.au>
	<CAEP_g=93aAXPk+A2u7LzAzEk6Fr33y7HiEMmXBCEkD8+B90kZQ@mail.gmail.com>
	<20130425084617.GA27463@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, horms@verge.net.au, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xeb@mail.ru
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50391 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754700Ab3DYJB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 05:01:59 -0400
In-Reply-To: <20130425084617.GA27463@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 25 Apr 2013 16:46:17 +0800

> Perhaps add an wrapper for the IS_ERR_OR_NULL with a descriptive
> name?

Or pick an error code for the case covered by NULL.
