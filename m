From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: ethernet: bgmac: Fix return value check in
 bgmac_probe()
Date: Mon, 11 Jul 2016 19:52:19 -0700 (PDT)
Message-ID: <20160711.195219.1516092377245302826.davem@davemloft.net>
References: <1468282648-1746-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, f.fainelli@gmail.com, jon.mason@broadcom.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35518 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932514AbcGLCwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 22:52:21 -0400
In-Reply-To: <1468282648-1746-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: weiyj_lk@163.com
Date: Tue, 12 Jul 2016 00:17:28 +0000

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> In case of error, the function devm_ioremap_resource() returns ERR_PTR()
> and never returns NULL. The NULL test in the return value check should be
> replaced with IS_ERR().
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thanks.
