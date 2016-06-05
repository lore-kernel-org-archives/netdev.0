From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] net: ethernet: cavium: liquidio: response_manager:
 Remove create_workqueue
Date: Sun, 5 Jun 2016 06:24:25 -0400
Message-ID: <20160605102425.GB31708@htj.duckdns.org>
References: <20160604145139.GA31437@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f68.google.com ([209.85.192.68]:36638 "EHLO
	mail-qg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753216AbcFEKY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 06:24:29 -0400
Content-Disposition: inline
In-Reply-To: <20160604145139.GA31437@Karyakshetra>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 04, 2016 at 08:21:40PM +0530, Bhaktipriya Shridhar wrote:
> alloc_workqueue replaces deprecated create_workqueue().
> 
> A dedicated workqueue has been used since the workitem viz
> (&cwq->wk.work which maps to oct_poll_req_completion) is involved
> in normal device operation. WQ_MEM_RECLAIM has been set to guarantee
> forward progress under memory pressure, which is a requirement here.
> Since there are only a fixed number of work items, explicit concurrency
> limit is unnecessary.
> 
> flush_workqueue is unnecessary since destroy_workqueue() itself calls
> drain_workqueue() which flushes repeatedly till the workqueue
> becomes empty. Hence the call to flush_workqueue() has been dropped.
> 
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>

As with the previous patch, the subject tag doesn't need to contain
the full hierarchy but other than that,

 Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
