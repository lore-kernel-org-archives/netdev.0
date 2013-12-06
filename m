From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/6] can: Fix FSF address in file headers
Date: Fri,  6 Dec 2013 06:28:45 -0800
Message-ID: <1386340128-23397-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386340128-23397-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27142 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755137Ab3LFO2x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 09:28:53 -0500
In-Reply-To: <1386340128-23397-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several files refer to an old address for the Free Software Foundation
in the file header comment.  Resolve by replacing the address with
the URL <http://www.gnu.org/licenses/> so that we do not have to keep
updating the header comments anytime the address changes.

CC: Wolfgang Grandegger <wg@grandegger.com>
CC: Marc Kleine-Budde <mkl@pengutronix.de>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/can/dev.c                         | 3 +--
 drivers/net/can/mcp251x.c                     | 3 +--
 drivers/net/can/mscan/mpc5xxx_can.c           | 3 +--
 drivers/net/can/mscan/mscan.c                 | 3 +--
 drivers/net/can/mscan/mscan.h                 | 3 +--
 drivers/net/can/pch_can.c                     | 3 +--
 drivers/net/can/sja1000/ems_pci.c             | 3 +--
 drivers/net/can/sja1000/kvaser_pci.c          | 3 +--
 drivers/net/can/sja1000/plx_pci.c             | 3 +--
 drivers/net/can/sja1000/sja1000_isa.c         | 3 +--
 drivers/net/can/sja1000/sja1000_of_platform.c | 3 +--
 drivers/net/can/sja1000/sja1000_platform.c    | 3 +--
 drivers/net/can/slcan.c                       | 4 +---
 drivers/net/can/softing/softing_cs.c          | 3 +--
 drivers/net/can/softing/softing_fw.c          | 3 +--
 drivers/net/can/softing/softing_main.c        | 3 +--
 16 files changed, 16 insertions(+), 33 deletions(-)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index bda1888..13a9098 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/module.h>
diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 08ac401..c4970c8 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -28,8 +28,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  *
  *
diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/mpc5xxx_can.c
index e59b3a3..035e235 100644
--- a/drivers/net/can/mscan/mpc5xxx_can.c
+++ b/drivers/net/can/mscan/mpc5xxx_can.c
@@ -16,8 +16,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/kernel.h>
diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index a955ec8..b9f3faa 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -16,8 +16,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/kernel.h>
diff --git a/drivers/net/can/mscan/mscan.h b/drivers/net/can/mscan/mscan.h
index e98abb9..ad8e08f 100644
--- a/drivers/net/can/mscan/mscan.h
+++ b/drivers/net/can/mscan/mscan.h
@@ -14,8 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef __MSCAN_H__
diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 5f0e9b3..79e8699 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -12,8 +12,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/interrupt.h>
diff --git a/drivers/net/can/sja1000/ems_pci.c b/drivers/net/can/sja1000/ems_pci.c
index 8359213..d790b87 100644
--- a/drivers/net/can/sja1000/ems_pci.c
+++ b/drivers/net/can/sja1000/ems_pci.c
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/kernel.h>
diff --git a/drivers/net/can/sja1000/kvaser_pci.c b/drivers/net/can/sja1000/kvaser_pci.c
index 087b13b..c96eb14 100644
--- a/drivers/net/can/sja1000/kvaser_pci.c
+++ b/drivers/net/can/sja1000/kvaser_pci.c
@@ -26,8 +26,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/kernel.h>
diff --git a/drivers/net/can/sja1000/plx_pci.c b/drivers/net/can/sja1000/plx_pci.c
index f9b4f81..5df7f98 100644
--- a/drivers/net/can/sja1000/plx_pci.c
+++ b/drivers/net/can/sja1000/plx_pci.c
@@ -16,8 +16,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/kernel.h>
diff --git a/drivers/net/can/sja1000/sja1000_isa.c b/drivers/net/can/sja1000/sja1000_isa.c
index 06a2823..df136a2 100644
--- a/drivers/net/can/sja1000/sja1000_isa.c
+++ b/drivers/net/can/sja1000/sja1000_isa.c
@@ -11,8 +11,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/kernel.h>
diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/net/can/sja1000/sja1000_of_platform.c
index 047accd..2f6e245 100644
--- a/drivers/net/can/sja1000/sja1000_of_platform.c
+++ b/drivers/net/can/sja1000/sja1000_of_platform.c
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 /* This is a generic driver for SJA1000 chips on the OpenFirmware platform
diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/can/sja1000/sja1000_platform.c
index 29f9b63..943df64 100644
--- a/drivers/net/can/sja1000/sja1000_platform.c
+++ b/drivers/net/can/sja1000/sja1000_platform.c
@@ -12,8 +12,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/kernel.h>
diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index 25377e5..3fcdae2 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -18,9 +18,7 @@
  * General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License along
- * with this program; if not, write to the Free Software Foundation, Inc.,
- * 59 Temple Place, Suite 330, Boston, MA 02111-1307. You can also get it
- * at http://www.gnu.org/licenses/gpl.html
+ * with this program; if not, see http://www.gnu.org/licenses/gpl.html
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
diff --git a/drivers/net/can/softing/softing_cs.c b/drivers/net/can/softing/softing_cs.c
index 498605f..cdc0c74 100644
--- a/drivers/net/can/softing/softing_cs.c
+++ b/drivers/net/can/softing/softing_cs.c
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/module.h>
diff --git a/drivers/net/can/softing/softing_fw.c b/drivers/net/can/softing/softing_fw.c
index b595d34..52fe507 100644
--- a/drivers/net/can/softing/softing_fw.c
+++ b/drivers/net/can/softing/softing_fw.c
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/firmware.h>
diff --git a/drivers/net/can/softing/softing_main.c b/drivers/net/can/softing/softing_main.c
index 6cd5c01..1b82127 100644
--- a/drivers/net/can/softing/softing_main.c
+++ b/drivers/net/can/softing/softing_main.c
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/module.h>
-- 
1.8.3.1
