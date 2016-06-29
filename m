From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: libertas_tf: Remove create_workqueue
Date: Wed, 29 Jun 2016 15:42:58 +0000 (UTC)
Message-ID: <20160629154258.60BFC613A6@smtp.codeaurora.org>
References: <20160607200853.GA13742@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes.berg@intel.com>, Tejun Heo <tj@kernel.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160607200853.GA13742@Karyakshetra>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bhaktipriya Shridhar <bhaktipriya96@gmail.com> wrote:
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
> Acked-by: Tejun Heo <tj@kernel.org>

Thanks, 1 patch applied to wireless-drivers-next.git:

452fa86e9806 libertas_tf: Remove create_workqueue

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9162447/
