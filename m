From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] bonding: Remove deprecated create_singlethread_workqueue
Date: Wed, 31 Aug 2016 10:05:29 -0400
Message-ID: <20160831140529.GE12660@htj.duckdns.org>
References: <20160830163201.GA25869@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <gospo@cumulusnetworks.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:32809 "EHLO
        mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934774AbcHaOFc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 10:05:32 -0400
Content-Disposition: inline
In-Reply-To: <20160830163201.GA25869@Karyakshetra>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 30, 2016 at 10:02:01PM +0530, Bhaktipriya Shridhar wrote:
> alloc_ordered_workqueue() with WQ_MEM_RECLAIM set, replaces
> deprecated create_singlethread_workqueue(). This is the identity
> conversion.
> 
> The workqueue "wq" queues multiple work items viz
> &bond->mcast_work, &nnw->work, &bond->mii_work, &bond->arp_work,
> &bond->alb_work, &bond->mii_work, &bond->ad_work, &bond->slave_arr_work
> which require strict execution ordering. Hence, an ordered dedicated
> workqueue has been used.
> 
> Since, it is a network driver, WQ_MEM_RECLAIM has been set to
> ensure forward progress under memory pressure.
> 
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
