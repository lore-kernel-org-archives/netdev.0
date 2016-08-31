From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] net: pegasus: Remove deprecated
 create_singlethread_workqueue
Date: Wed, 31 Aug 2016 10:23:05 -0400
Message-ID: <20160831142305.GI12660@htj.duckdns.org>
References: <20160830163247.GA25925@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Petko Manolov <petkan@nucleusys.com>, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:36619 "EHLO
        mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934324AbcHaOXH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 10:23:07 -0400
Content-Disposition: inline
In-Reply-To: <20160830163247.GA25925@Karyakshetra>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 30, 2016 at 10:02:47PM +0530, Bhaktipriya Shridhar wrote:
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

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
