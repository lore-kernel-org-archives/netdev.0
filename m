From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 925/931] include/linux/rhashtable.h:522:13:
 error: 'EEXIST' undeclared
Date: Fri, 20 Mar 2015 18:19:16 -0400 (EDT)
Message-ID: <20150320.181916.1312726749034676278.davem@davemloft.net>
References: <201503210420.crMKxZr4%fengguang.wu@intel.com>
	<20150320213251.GD23301@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, kbuild-all@01.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39263 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbbCTWTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 18:19:18 -0400
In-Reply-To: <20150320213251.GD23301@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 21 Mar 2015 08:32:51 +1100

> rhashtable: Fix undeclared EEXIST build error on ia64
> 
> We need to include linux/errno.h in rhashtable.h since it doesn't
> always get included otherwise.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
