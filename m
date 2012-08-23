From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rds: Don't disable BH on BH context
Date: Wed, 22 Aug 2012 22:52:15 -0700 (PDT)
Message-ID: <20120822.225215.1469285308925066749.davem@davemloft.net>
References: <1345448648-30449-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: venkat.x.venkatsubra@oracle.com, netdev@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33414 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754315Ab2HWFwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 01:52:16 -0400
In-Reply-To: <1345448648-30449-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Mon, 20 Aug 2012 15:44:08 +0800

> Since we have already in BH context when *_write_space(),
> *_data_ready() as well as *_state_change() are called, it's
> unnecessary to disable BH.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Applied to net-next, thanks.
