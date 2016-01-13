From: Kejian Yan <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [patch v3 net-next 0/2] dts: hisi: fixes no syscon fault when init mdio
Date: Wed, 13 Jan 2016 11:01:11 +0800
Message-ID: <1452654073-28039-2-git-send-email-yankejian@huawei.com>
References: <1452654073-28039-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	<mark.rutland-5wv7dgnIgG8@public.gmane.org>, <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	<galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
	<will.deacon-5wv7dgnIgG8@public.gmane.org>, <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	<liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <arnd-r2nGTMty4D4@public.gmane.org>, <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	<lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1452654073-28039-1-git-send-email-yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patchset fixes the bug that eth can't initial successful on hip05-D02
because the dts files doesn't match the source code.

Kejian Yan (2):
  dts: hisi: fixes no syscon fault when init mdio
  net: hns: fixes no syscon error when init mdio
---
change log:
v3:
 1) uses capital letter at the beginning of sentences
 2) updates the right device node name

v2:
 1) update the related documented in the binding as well
 2) use the normal naming conventions using '-' instead of '_', and
    update the related *.c files.
v1:
 first submit

 .../devicetree/bindings/arm/hisilicon/hisilicon.txt      | 16 ++++++++++++++++
 arch/arm64/boot/dts/hisilicon/hip05.dtsi                 |  5 +++++
 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi             |  4 ++--
 drivers/net/ethernet/hisilicon/hns_mdio.c                |  2 +-
 4 files changed, 24 insertions(+), 3 deletions(-)

-- 
2.4.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
