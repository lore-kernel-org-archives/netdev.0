From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: pasemi: fix return value check in
 pasemi_mac_phy_init()
Date: Thu, 27 Sep 2012 13:21:15 -0400 (EDT)
Message-ID: <20120927.132115.2182914790094588188.davem@davemloft.net>
References: <CAPgLHd8hJjj1HkV7gc8QH2p9rDJQedkc+vCUpFJMgyXQua4LGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: olof@lixom.net, grant.likely@secretlab.ca, rob.herring@calxeda.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55475 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977Ab2I0RVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 13:21:17 -0400
In-Reply-To: <CAPgLHd8hJjj1HkV7gc8QH2p9rDJQedkc+vCUpFJMgyXQua4LGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Thu, 27 Sep 2012 13:51:58 +0800

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
