From: yankejian <yankejian@huawei.com>
Subject: [PATCH RESEND net-next 1/3] dts: hisi: enables the ethX for D02 board
Date: Sat, 5 Dec 2015 15:56:56 +0800
Message-ID: <1449302218-54374-2-git-send-email-yankejian@huawei.com>
References: <1449302218-54374-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, haifeng.wei@huawei.com, netdev@vger.kernel.org,
 linuxarm@huawei.com, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: <davem@davemloft.net>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
 <mark.rutland@arm.com>, <ijc+devicetree@hellion.org.uk>,
 <galak@codeaurora.org>, <xuwei5@hisilicon.com>,
 <catalin.marinas@arm.com>, <will.deacon@arm.com>,
 <wangkefeng.wang@huawei.com>, <dingtianhong@huawei.com>,
 <liguozhu@huawei.com>, <Yisen.Zhuang@huawei.com>,
 <sboyd@codeaurora.org>, <haojian.zhuang@linaro.org>,
 <wangzhou1@hisilicon.com>, <bintian.wang@huawei.com>,
 <long.wanglong@huawei.com>, <leo.yan@linaro.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1449302218-54374-1-git-send-email-yankejian@huawei.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

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
