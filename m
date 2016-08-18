From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: [PATCH V2 10/10] MIPS: xilfpga: Update defconfig
Date: Thu, 18 Aug 2016 14:43:24 +0100
Message-ID: <1471527804-26175-11-git-send-email-Zubair.Kakakhel@imgtec.com>
References: <1471527804-26175-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jason@lakedaemon.net>, <marc.zyngier@arm.com>,
	<linux-mips@linux-mips.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <Zubair.Kakakhel@imgtec.com>
To: <monstr@monstr.eu>, <ralf@linux-mips.org>, <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471527804-26175-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update defconfig to enable emaclite, i2c, temp sensor found on the
xilfpga platform

Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>

---
V1 -> V2
No change
---
 arch/mips/configs/xilfpga_defconfig | 37 ++++++++++++++++++++++++++++++++++++-
 1 file changed, 36 insertions(+), 1 deletion(-)

diff --git a/arch/mips/configs/xilfpga_defconfig b/arch/mips/configs/xilfpga_defconfig
index ed1dce3..829c637 100644
--- a/arch/mips/configs/xilfpga_defconfig
+++ b/arch/mips/configs/xilfpga_defconfig
@@ -7,6 +7,12 @@ CONFIG_EMBEDDED=y
 CONFIG_SLAB=y
 # CONFIG_BLOCK is not set
 # CONFIG_SUSPEND is not set
+CONFIG_NET=y
+CONFIG_PACKET=y
+CONFIG_UNIX=y
+CONFIG_INET=y
+# CONFIG_IPV6 is not set
+# CONFIG_WIRELESS is not set
 # CONFIG_UEVENT_HELPER is not set
 CONFIG_DEVTMPFS=y
 CONFIG_DEVTMPFS_MOUNT=y
@@ -14,6 +20,30 @@ CONFIG_DEVTMPFS_MOUNT=y
 # CONFIG_PREVENT_FIRMWARE_BUILD is not set
 # CONFIG_FW_LOADER is not set
 # CONFIG_ALLOW_DEV_COREDUMP is not set
+CONFIG_NETDEVICES=y
+# CONFIG_NET_CORE is not set
+# CONFIG_NET_VENDOR_ARC is not set
+# CONFIG_NET_CADENCE is not set
+# CONFIG_NET_VENDOR_BROADCOM is not set
+# CONFIG_NET_VENDOR_EZCHIP is not set
+# CONFIG_NET_VENDOR_INTEL is not set
+# CONFIG_NET_VENDOR_MARVELL is not set
+# CONFIG_NET_VENDOR_MICREL is not set
+# CONFIG_NET_VENDOR_NATSEMI is not set
+# CONFIG_NET_VENDOR_NETRONOME is not set
+# CONFIG_NET_VENDOR_QUALCOMM is not set
+# CONFIG_NET_VENDOR_RENESAS is not set
+# CONFIG_NET_VENDOR_ROCKER is not set
+# CONFIG_NET_VENDOR_SAMSUNG is not set
+# CONFIG_NET_VENDOR_SEEQ is not set
+# CONFIG_NET_VENDOR_SMSC is not set
+# CONFIG_NET_VENDOR_STMICRO is not set
+# CONFIG_NET_VENDOR_SYNOPSYS is not set
+# CONFIG_NET_VENDOR_VIA is not set
+# CONFIG_NET_VENDOR_WIZNET is not set
+CONFIG_XILINX_EMACLITE=y
+CONFIG_SMSC_PHY=y
+# CONFIG_WLAN is not set
 # CONFIG_INPUT_MOUSEDEV is not set
 # CONFIG_INPUT_KEYBOARD is not set
 # CONFIG_INPUT_MOUSE is not set
@@ -25,13 +55,18 @@ CONFIG_SERIAL_8250=y
 CONFIG_SERIAL_8250_CONSOLE=y
 CONFIG_SERIAL_OF_PLATFORM=y
 # CONFIG_HW_RANDOM is not set
+CONFIG_I2C=y
+CONFIG_I2C_CHARDEV=y
+# CONFIG_I2C_HELPER_AUTO is not set
+CONFIG_I2C_XILINX=y
 CONFIG_GPIO_SYSFS=y
 CONFIG_GPIO_XILINX=y
-# CONFIG_HWMON is not set
+CONFIG_SENSORS_ADT7410=y
 # CONFIG_USB_SUPPORT is not set
 # CONFIG_MIPS_PLATFORM_DEVICES is not set
 # CONFIG_IOMMU_SUPPORT is not set
 # CONFIG_PROC_PAGE_MONITOR is not set
+CONFIG_TMPFS=y
 # CONFIG_MISC_FILESYSTEMS is not set
 CONFIG_PANIC_ON_OOPS=y
 # CONFIG_SCHED_DEBUG is not set
-- 
1.9.1
