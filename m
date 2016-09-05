From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH for-next 0/2] {IB,net}/hns: Add support of ACPI to the
 Hisilicon RoCE Driver
Date: Mon, 05 Sep 2016 12:41:37 -0700 (PDT)
Message-ID: <20160905.124137.1197811755644672169.davem@davemloft.net>
References: <20160824.215341.1803699371957253329.davem@davemloft.net>
        <d71edae9-805a-2000-9afa-7e8002bc498a@redhat.com>
        <F4CC6FACFEB3C54C9141D49AD221F7F91A6F9F0D@lhreml503-mbx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
        yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F91A6F9F0D@lhreml503-mbx>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Date: Mon, 5 Sep 2016 12:53:07 +0000

> There is a patch in net-next for HNS Ethernet driver which has been accepted.
> "b3dc935 net: hns: remove redundant dev_err call in hns_dsaf_get_cfg()"
> 
> This patch is creating conflict with Doug Ledford's hns-roce branch. Internally,
> We have decided to let all the HNS patches pass through the hns-roce for 4.9
> Merge window to facilitate non-conflict merge of pending RoCE driver by Doug Ledford.
> 
> Though, we are trying to take a grip of the process for this merge window but
> Somehow this one bypassed the internal process. This will create problems for
> Hns-roce during merge later this window. Can I request you to drop this patch
> For now. We shall re-submit this patch later when things have been settled at
> the RoCE/RDMA end or would come again to you through hns-roce branch.
> 
> Please let me know if this is possible this time. Thanks in anticipation!

This cannot work like this.

If I see an obvious fix to something in networking, I will apply the
patch.

Merge conflicts happen and they have to be resolved.

We don't just revert legitimate changes to eliminate the conflict.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
