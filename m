From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 0/3] Misc. Bug fixes for HNS3 Ethernet Driver
Date: Fri, 18 Aug 2017 12:31:36 +0100
Message-ID: <20170818113139.153200-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        <lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch-set fixes various bugs reported by community.

Salil Mehta (3):
  net: hns3: Fixes the missing u64_stats_fetch_begin_irq in 64-bit stats
    fetch
  net: hns3: Fixes the static checker error warning in
    hns3_get_link_ksettings()
  net: hns3: Fixes the static check warning due to missing unsupp L3
    proto check

 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 16 +++-
 .../ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c  | 85 ++++++++++++----------
 2 files changed, 60 insertions(+), 41 deletions(-)

-- 
2.7.4


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
