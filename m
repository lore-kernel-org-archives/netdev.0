From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] libertas_tf: Remove create_workqueue
Date: Sat, 11 Jun 2016 17:47:08 -0500
Message-ID: <20160611224708.GC31708@htj.duckdns.org>
References: <20160607200853.GA13742@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kalle Valo <kvalo@codeaurora.org>,
	Johannes Berg <johannes.berg@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35468 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896AbcFKWrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 18:47:17 -0400
Content-Disposition: inline
In-Reply-To: <20160607200853.GA13742@Karyakshetra>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 08, 2016 at 01:38:53AM +0530, Bhaktipriya Shridhar wrote:
> alloc_workqueue replaces deprecated create_workqueue().
> 
> A dedicated workqueue has been used since the workitem (viz
> &priv->cmd_work per priv, which maps to lbtf_cmd_work) is involved in
> actual command processing and may be used on a memory reclaim path.
> The workitems require forward progress under memory pressure and hence,
> WQ_MEM_RECLAIM has been set. Since there are only a fixed number of work
> items, explicit concurrency limit is unnecessary here.
> 
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
