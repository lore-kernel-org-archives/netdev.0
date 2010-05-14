From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 02/25] wimax/i2400m: move I2400M_MAX_MTU enum from
	netdev.c to i2400m.h
Date: Fri, 14 May 2010 14:45:01 -0700
Message-ID: <080de04e6229c49be41b811f5d5429afd6ed736d.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Prasanna S. Panchamukhi" <prasannax.s.panchamukhi@intel.com>
To: netdev@vger.kernel.org,
	wimax@linuxwimax.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
List-Unsubscribe: <http://lists.linuxwimax.org/options/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.linuxwimax.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://lists.linuxwimax.org/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

From: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>

This patch moves I2400M_MAX_MTU enum defined in netdev.c to i2400m.h.
Follow up changes will make use of this value in other location,
thus requiring it to be moved to a global header file i2400m.h.

Signed-off-by: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/i2400m.h |   10 ++++++++++
 drivers/net/wimax/i2400m/netdev.c |    6 ------
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 820b128..da218b9 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -160,6 +160,16 @@
 #include <linux/wimax/i2400m.h>
 #include <asm/byteorder.h>
 
+enum {
+/* netdev interface */
+	/*
+	 * Out of NWG spec (R1_v1.2.2), 3.3.3 ASN Bearer Plane MTU Size
+	 *
+	 * The MTU is 1400 or less
+	 */
+	I2400M_MAX_MTU = 1400,
+};
+
 /* Misc constants */
 enum {
 	/* Size of the Boot Mode Command buffer */
diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index b811c2f..fc3754a 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -84,12 +84,6 @@
 
 enum {
 /* netdev interface */
-	/*
-	 * Out of NWG spec (R1_v1.2.2), 3.3.3 ASN Bearer Plane MTU Size
-	 *
-	 * The MTU is 1400 or less
-	 */
-	I2400M_MAX_MTU = 1400,
 	/* 20 secs? yep, this is the maximum timeout that the device
 	 * might take to get out of IDLE / negotiate it with the base
 	 * station. We add 1sec for good measure. */
-- 
1.6.6.1
