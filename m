From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] cxgb4vf: Interrupt and queue
 configuration changes
Date: Thu, 10 Mar 2016 16:12:51 -0500 (EST)
Message-ID: <20160310.161251.312403485038819803.davem@davemloft.net>
References: <1457414420-5237-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932230AbcCJVMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 16:12:53 -0500
In-Reply-To: <1457414420-5237-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue,  8 Mar 2016 10:50:16 +0530

> This series fixes some issues and some changes in the queue and interrupt
> configuration for cxgb4vf driver. We need to enable interrupts before we
> register our network device, so that we don't loose link up interrupts.
> Allocate rx queues based on interrupt type. Set number of tx/rx queues in
> probe function only. Also adds check for some invalid configurations.
> 
> This patch series has been created against net-next tree and includes
> patches on cxgb4vf driver.
> 
> We have included all the maintainers of respective drivers. Kindly review
> the change and let us know in case of any review comments.

Series applied, thanks.
