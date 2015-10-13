From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] BNX2: free temp_stats_blk on error path
Date: Mon, 12 Oct 2015 19:34:13 -0700 (PDT)
Message-ID: <20151012.193413.388189317101084732.davem@davemloft.net>
References: <561C66DF.2080302@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manish.chopra@qlogic.com, Dept-HSGLinuxNICDev@qlogic.com,
	sony.chacko@qlogic.com, netdev@vger.kernel.org
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43043 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524AbbJMCSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 22:18:15 -0400
In-Reply-To: <561C66DF.2080302@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weidong Wang <wangweidong1@huawei.com>
Date: Tue, 13 Oct 2015 10:05:19 +0800

> In bnx2_init_board, missing free temp_stats_blk on error path when
> some operations do failed. Just add the 'kfree' operation.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Applied, thanks.
