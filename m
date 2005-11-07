From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.14 (take #2)] fec_8xx: make CONFIG_FEC_8XX depend on CONFIG_8xx
Date: Mon, 7 Nov 2005 13:24:59 -0500
Message-ID: <20051107182459.GD13797@tuxdriver.com>
References: <20051106025701.GA9698@tuxdriver.com> <436F07F5.1030206@intracom.gr> <20051107182031.GC13797@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964879AbVKGSZP@vger.kernel.org>
To: Pantelis Antoniou <panto@intracom.gr>,
	linuxppc-embedded@ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20051107182031.GC13797@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change CONFIG_FEC_8XX to depend on CONFIG_8xx instead of CONFIG_FEC.
CONFIG_FEC depends on ColdFire CPUs, which does not apply for the
PPC 8xx processors.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/fec_8xx/Kconfig |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/fec_8xx/Kconfig b/drivers/net/fec_8xx/Kconfig
index 94e7a9a..a84c232 100644
--- a/drivers/net/fec_8xx/Kconfig
+++ b/drivers/net/fec_8xx/Kconfig
@@ -1,6 +1,6 @@
 config FEC_8XX
 	tristate "Motorola 8xx FEC driver"
-	depends on NET_ETHERNET && FEC
+	depends on NET_ETHERNET && 8xx
 	select MII
 
 config FEC_8XX_GENERIC_PHY
-- 
John W. Linville
linville@tuxdriver.com
