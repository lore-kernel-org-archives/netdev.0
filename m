From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [RESEND PATCH 0/3] hisilicon hns warning fixes for gcc-7.0.1
Date: Fri, 24 Mar 2017 23:02:47 +0100
Message-ID: <20170324220250.2193128-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        "Wei Hu(Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        Daode Huang <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
        Kejian Yan <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        Qianqian Xie <xieqianqian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        Wei Yongjun <weiyongjun1-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        Yisen Zhuang <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Building with gcc-7 found three new warnings in the hns ethernet and
rdma drivers. Only one of them appears to be an actual bug, the
other two are variations of a single problem, but are unfortunately
part of different subsystems.

I'm resending all three patches to both the ethernet and the rdma
maintainers, as the first submission was a bit confusing when only
part of the series arrived for a subset of maintainers, sorry about
that.

All three patches are address issues in released kernels
and apply to v4.11-rc3 or linux-next.

      Arnd

Arnd Bergmann
  net: hns: fix uninitialized data use
  net: hns: avoid gcc-7.0.1 warning for uninitialized data
  infiniband: hns: avoid gcc-7.0.1 warning for uninitialized data

 drivers/infiniband/hw/hns/hns_roce_hw_v1.c         | 1 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

-- 
2.9.0

Cc: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: "Wei Hu(Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Daode Huang <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Cc: Kejian Yan <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Qianqian Xie <xieqianqian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Wei Yongjun <weiyongjun1-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Yisen Zhuang <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
