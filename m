From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: octeon: fix return value check in
 octeon_mgmt_init_phy()
Date: Fri, 28 Sep 2012 01:18:52 -0400 (EDT)
Message-ID: <20120928.011852.1655132706872190960.davem@davemloft.net>
References: <CAPgLHd-Tk9eFL2Sj-7_TZA0ngWejuL69=qzENNG_CrJpaQ_S8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@secretlab.ca, rob.herring@calxeda.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34118 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900Ab2I1FS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 01:18:58 -0400
In-Reply-To: <CAPgLHd-Tk9eFL2Sj-7_TZA0ngWejuL69=qzENNG_CrJpaQ_S8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Fri, 28 Sep 2012 13:04:21 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> In case of error, the function of_phy_connect() returns NULL
> pointer not ERR_PTR(). The IS_ERR() test in the return value
> check should be replaced with NULL test.
> 
> dpatch engine is used to auto generate this patch.
> (https://github.com/weiyj/dpatch)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thanks.
