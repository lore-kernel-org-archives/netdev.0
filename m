From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 net-next] qed*: Utilize Firmware 8.15.3.0
Date: Mon, 13 Mar 2017 15:33:47 -0700 (PDT)
Message-ID: <20170313.153347.308062967844295379.davem@davemloft.net>
References: <1489250358-28955-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tomer.Tayar-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
        Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, Manish.Rangankar-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
        Chad.Dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
To: Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489250358-28955-1-git-send-email-Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Date: Sat, 11 Mar 2017 18:39:18 +0200

> This patch advances the qed* drivers into using the newer firmware -
> This solves several firmware bugs, mostly related [but not limited to]
> various init/deinit issues in various offloaded protocols.
> 
> It also introduces a major 4-Cached SGE change in firmware, which can be
> seen in the storage drivers' changes.
> 
> In addition, this firmware is required for supporting the new QL41xxx
> series of adapters; While this patch doesn't add the actual support,
> the firmware contains the necessary initialization & firmware logic to
> operate such adapters [actual support would be added later on].
> 
> Changes from Previous versions:
> -------------------------------
>  - V2 - fix kbuild-test robot warnings
> 
> Signed-off-by: Tomer Tayar <Tomer.Tayar-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Manish Rangankar <Manish.Rangankar-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Chad Dupuis <Chad.Dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
