From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next v2] net: hns: fix return value check in
 hns_dsaf_get_cfg()
Date: Tue, 05 Jul 2016 10:21:36 -0700 (PDT)
Message-ID: <20160705.102136.1046702907087413810.davem@davemloft.net>
References: <1467644458-10131-1-git-send-email-weiyj_lk@163.com>
	<1467705412-30194-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
	yankejian@huawei.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38802 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878AbcGERVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 13:21:38 -0400
In-Reply-To: <1467705412-30194-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: weiyj_lk@163.com
Date: Tue,  5 Jul 2016 07:56:52 +0000

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> In case of error, function devm_ioremap_resource() returns ERR_PTR()
> and never returns NULL. The NULL test in the return value check should
> be replaced with IS_ERR().
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thanks.
