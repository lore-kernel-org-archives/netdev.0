From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: [PATCH 3/3] ARM: configs: keystone: Enable D_CAN driver
Date: Wed, 2 Aug 2017 15:18:22 -0500
Message-ID: <20170802201822.11532-4-fcooper@ti.com>
References: <20170802201822.11532-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Franklin S Cooper Jr <fcooper@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
 <ssantosh@kernel.org>, <linux@armlinux.org.uk>,
 <linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
 <devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
 <linux-arm-kernel@lists.infradead.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170802201822.11532-1-fcooper@ti.com>
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

Enable C_CAN/D_CAN driver supported by 66AK2G

Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
---
 arch/arm/configs/keystone_defconfig | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/arm/configs/keystone_defconfig b/arch/arm/configs/keystone_defconfig
index d47ea43..47be99e 100644
--- a/arch/arm/configs/keystone_defconfig
+++ b/arch/arm/configs/keystone_defconfig
@@ -112,6 +112,9 @@ CONFIG_IP_NF_ARP_MANGLE=y
 CONFIG_IP6_NF_IPTABLES=m
 CONFIG_IP_SCTP=y
 CONFIG_VLAN_8021Q=y
+CONFIG_CAN=m
+CONFIG_CAN_C_CAN=m
+CONFIG_CAN_C_CAN_PLATFORM=m
 CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
 CONFIG_DEVTMPFS=y
 CONFIG_DEVTMPFS_MOUNT=y
-- 
2.9.4.dirty
