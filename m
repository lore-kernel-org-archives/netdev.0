From: yankejian <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 0/2] net: hns: enet specisies a reference to dsaf
Date: Sat, 5 Dec 2015 14:10:54 +0800
Message-ID: <1449295856-31068-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <arnd-r2nGTMty4D4@public.gmane.org>, <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<catalin.marinas-5wv7dgnIgG8@public.gmane.org>, <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	<salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

in this patchset, enet specifies a reference to dsaf. and delete the 
ae-name in enet, and adds parsing the ae-handle from DT to set the 
associating with dsaf.
the patchset updates the dtsi and bindings documents as well.

yankejian (2):
  net: hns: enet specisies a reference to dsaf
  net: hns: enet specisies a reference to dsaf (config and documents)

 .../devicetree/bindings/net/hisilicon-hns-dsaf.txt    |  5 +----
 .../devicetree/bindings/net/hisilicon-hns-nic.txt     |  7 ++++---
 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi          | 19 +++++++++----------
 drivers/net/ethernet/hisilicon/hns/hnae.c             | 17 +++++++----------
 drivers/net/ethernet/hisilicon/hns/hnae.h             |  7 +++++--
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c     |  4 ++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c    | 10 +---------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h    |  1 +
 drivers/net/ethernet/hisilicon/hns/hns_enet.c         | 13 +++++++++----
 drivers/net/ethernet/hisilicon/hns/hns_enet.h         |  2 +-
 10 files changed, 42 insertions(+), 43 deletions(-)

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
