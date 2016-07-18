From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dwc_eth_qos: Remove deprecated
 create_singlethread_workqueue
Date: Sun, 17 Jul 2016 22:27:58 -0700 (PDT)
Message-ID: <20160717.222758.2271369406708475258.davem@davemloft.net>
References: <20160716082328.GA7254@Karyakshetra>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lars.persson@axis.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tj@kernel.org
To: bhaktipriya96@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbcGRF17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 01:27:59 -0400
In-Reply-To: <20160716082328.GA7254@Karyakshetra>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Date: Sat, 16 Jul 2016 13:53:28 +0530

> alloc_workqueue replaces deprecated create_singlethread_workqueue().
> 
> A dedicated workqueue has been used since the workitem viz
> lp->txtimeout_reinit is involved in reinitialization if a TX timeout
> occurs, which is necessary to guarantee forward progress in packet
> processing. As a network device can be used during memory reclaim, the
> workqueue needs forward progress guarantee under memory pressure.
> WQ_MEM_RECLAIM has been set to ensure this.
> 
> Since there is only a single work item, explicit concurrency limit is
> unnecessary here.
> 
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>

Applied.
