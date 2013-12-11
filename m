From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: remove redundant null check on asoc
Date: Wed, 11 Dec 2013 15:39:59 -0500 (EST)
Message-ID: <20131211.153959.2037422735738904875.davem@davemloft.net>
References: <52A82566.1050601@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59358 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030Ab3LKUkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 15:40:02 -0500
In-Reply-To: <52A82566.1050601@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>
Date: Wed, 11 Dec 2013 16:42:14 +0800

> In sctp_err_lookup, goto out while the asoc is not NULL, so remove the
> check NULL. Also, in sctp_err_finish which called by sctp_v4_err and
> sctp_v6_err, they pass asoc to sctp_err_finish while the asoc is not
> NULL, so remove the check.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Applied, thanks.
