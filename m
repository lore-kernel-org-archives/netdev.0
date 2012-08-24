From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wimax/i2400m: use is_zero_ether_addr() instead of
 memcmp()
Date: Fri, 24 Aug 2012 13:30:37 -0400 (EDT)
Message-ID: <20120824.133037.2004197798034785394.davem@davemloft.net>
References: <CAPgLHd9_MkQcGbQEqf=6Kjm06juybu29qSBdd7T=_EenFDyuEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: inaky.perez-gonzalez@intel.com, yongjun_wei@trendmicro.com.cn,
	linux-wimax@intel.com, wimax@linuxwimax.org, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54571 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756062Ab2HXRak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 13:30:40 -0400
In-Reply-To: <CAPgLHd9_MkQcGbQEqf=6Kjm06juybu29qSBdd7T=_EenFDyuEQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Thu, 23 Aug 2012 14:49:33 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Using is_zero_ether_addr() instead of directly use
> memcmp() to determine if the ethernet address is all
> zeros.
> 
> spatch with a semantic match is used to found this problem.
> (http://coccinelle.lip6.fr/)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
