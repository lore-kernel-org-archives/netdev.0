From: yankejian <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 0/3] dts: hisi: fixes can't find eth for hip05-D02
Date: Sat, 28 Nov 2015 14:15:13 +0800
Message-ID: <1448691316-236111-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	<mark.rutland-5wv7dgnIgG8@public.gmane.org>, <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	<galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	<catalin.marinas-5wv7dgnIgG8@public.gmane.org>, <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	<wangkefeng.wang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, <haojian.zhuang-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<wangzhou1-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <bintian.wang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<long.wanglong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <leo.yan-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

this patchset fixes the bug that eth can't initial successful. because the
the dts files doesn't match the source code.

yankejian (3):
  dts: hisi: enables the ethX for D02 board
  dts: hisi: fixes no syscon error when init mdio
  arm64: hip05-d02: Document devicetree bindings for Hisilicon D02 Board

 .../devicetree/bindings/arm/hisilicon/hisilicon.txt      | 16 ++++++++++++++++
 arch/arm64/boot/dts/hisilicon/hip05-d02.dts              | 16 ++++++++++++++++
 arch/arm64/boot/dts/hisilicon/hip05.dtsi                 |  4 ++++
 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi             |  4 ++--
 4 files changed, 38 insertions(+), 2 deletions(-)

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
