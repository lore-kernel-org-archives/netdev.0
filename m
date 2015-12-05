From: yankejian <yankejian@huawei.com>
Subject: [PATCH RESEND net-next 1/3] dts: hisi: enables the ethX for D02 board
Date: Sat, 5 Dec 2015 15:54:46 +0800
Message-ID: <1449302088-53037-2-git-send-email-yankejian@huawei.com>
References: <1449302088-53037-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <haifeng.wei@huawei.com>, <devicetree@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>
To: <davem@davemloft.net>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
	<mark.rutland@arm.com>, <ijc+devicetree@hellion.org.uk>,
	<galak@codeaurora.org>, <xuwei5@hisilicon.com>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<wangkefeng.wang@huawei.com>, <dingtianhong@huawei.com>,
	<liguozhu@huawei.com>, <Yisen.Zhuang@huawei.com>,
	<sboyd@codeaurora.org>, <haojian.zhuang@linaro.org>,
	<wangzhou1@hisilicon.com>, <bintian.wang@huawei.com>,
	<long.wanglong@huawei.com>, <leo.yan@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:31871 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147AbbLEHjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 02:39:48 -0500
In-Reply-To: <1449302088-53037-1-git-send-email-yankejian@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this patch enables the ethX for D02 board on hip05-d02.dts. otherwise it
cannot find hns ethX by ifconfig -a.

Signed-off-by: yankejian <yankejian@huawei.com>
---
 arch/arm64/boot/dts/hisilicon/hip05-d02.dts | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/arch/arm64/boot/dts/hisilicon/hip05-d02.dts b/arch/arm64/boot/dts/hisilicon/hip05-d02.dts
index ae34e25..6aa5cb2 100644
--- a/arch/arm64/boot/dts/hisilicon/hip05-d02.dts
+++ b/arch/arm64/boot/dts/hisilicon/hip05-d02.dts
@@ -34,3 +34,19 @@
 &uart0 {
 	status = "ok";
 };
+
+&eth2 {
+	status = "okay";
+};
+
+&eth3 {
+	status = "okay";
+};
+
+&eth6 {
+	status = "okay";
+};
+
+&eth7 {
+	status = "okay";
+};
-- 
1.9.1
