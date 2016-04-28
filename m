From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 0/4] net: hns: update DT properties according to Rob's comments
Date: Thu, 28 Apr 2016 15:09:00 +0800
Message-ID: <1461827344-52230-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<davem@davemloft.net>, <will.deacon@arm.com>,
	<catalin.marinas@arm.com>, <yankejian@huawei.com>,
	<huangdaode@hisilicon.com>, <salil.mehta@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>,
	<xieqianqian@huawei.com>, <xuwei5@hisilicon.com>,
	<linuxarm@huawei.com>
To: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:5442 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693AbcD1Gwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 02:52:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some inappropriate properties definition in hns DT. We update the definition
according to Rob's review comments and fix some typos in binding.

For more details, please see individual patches.

MBR.

Yisen Zhuang (4):
  net: hns: remove cpld-ctrl-reg and add cell in the cpld-syscon
    property
  net: hns: change port-id property to reg property in dsaf port node
  Documentation: Bindings: Update DT binding for hns dsaf node
  dts: hisi: update hns dst for changing property port-id to reg

 .../devicetree/bindings/net/hisilicon-hns-dsaf.txt | 28 +++++++++----------
 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi       | 10 ++++---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 32 ++++++++++++----------
 3 files changed, 36 insertions(+), 34 deletions(-)

-- 
1.9.1
