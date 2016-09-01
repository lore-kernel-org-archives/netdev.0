From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: pegasus: Remove deprecated
 create_singlethread_workqueue
Date: Thu, 01 Sep 2016 16:42:40 -0700 (PDT)
Message-ID: <20160901.164240.287180419520196259.davem@davemloft.net>
References: <20160830163247.GA25925@Karyakshetra>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: petkan@nucleusys.com, tj@kernel.org, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bhaktipriya96@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40846 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751252AbcIAXml (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 19:42:41 -0400
In-Reply-To: <20160830163247.GA25925@Karyakshetra>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Date: Tue, 30 Aug 2016 22:02:47 +0530

> The workqueue "pegasus_workqueue" queues a single work item per pegasus
> instance and hence it doesn't require execution ordering. Hence,
> alloc_workqueue has been used to replace the deprecated
> create_singlethread_workqueue instance.
> 
> The WQ_MEM_RECLAIM flag has been set to ensure forward progress under
> memory pressure since it's a network driver.
> 
> Since there are fixed number of work items, explicit concurrency
> limit is unnecessary here.
> 
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>

Applied.
