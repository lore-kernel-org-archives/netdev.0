From: David Miller <davem@davemloft.net>
Subject: Re: [rhashtable] [ INFO: possible recursive locking detected ]
Date: Thu, 12 Mar 2015 00:25:16 -0400 (EDT)
Message-ID: <20150312.002516.1995642240704082223.davem@davemloft.net>
References: <20150312033744.GA13869@gondor.apana.org.au>
	<20150311.234156.247575265894541661.davem@davemloft.net>
	<20150312034713.GA14026@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, lkp@01.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56352 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbbCLEZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 00:25:19 -0400
In-Reply-To: <20150312034713.GA14026@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 12 Mar 2015 14:47:13 +1100

> rhashtable: Add annotation to nested lock
>     
> Commit aa34a6cb0478842452bac58edb50d3ef9e178c92 ("rhashtable:
> Add arbitrary rehash function") killed the annotation on the
> nested lock which leads to bitching from lockdep.
>     
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks!
