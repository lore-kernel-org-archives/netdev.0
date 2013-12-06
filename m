From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/6] usb: Fix FSF address in file headers
Date: Fri,  6 Dec 2013 06:28:46 -0800
Message-ID: <1386340128-23397-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386340128-23397-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Oliver Neukum <oliver@neukum.org>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	Oliver Neukum <oneukum@suse.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27142 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755196Ab3LFO2y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 09:28:54 -0500
In-Reply-To: <1386340128-23397-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several files refer to an old address for the Free Software Foundation
in the file header comment.  Resolve by replacing the address with
the URL <http://www.gnu.org/licenses/> so that we do not have to keep
updating the header comments anytime the address changes.

CC: Oliver Neukum <oliver@neukum.org>
CC: Steve Glendinning <steve.glendinning@shawell.net>
CC: Oliver Neukum <oneukum@suse.de>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/usb/asix.h         | 3 +--
 drivers/net/usb/asix_common.c  | 3 +--
 drivers/net/usb/asix_devices.c | 3 +--
 drivers/net/usb/ax88172a.c     | 3 +--
 drivers/net/usb/ax88179_178a.c | 3 +--
 drivers/net/usb/catc.c         | 3 +--
 drivers/net/usb/cdc_eem.c      | 3 +--
 drivers/net/usb/cdc_ether.c    | 3 +--
 drivers/net/usb/cdc_subset.c   | 3 +--
 drivers/net/usb/cx82310_eth.c  | 3 +--
 drivers/net/usb/gl620a.c       | 3 +--
 drivers/net/usb/int51x1.c      | 3 +--
 drivers/net/usb/kaweth.c       | 3 +--
 drivers/net/usb/lg-vl600.c     | 3 +--
 drivers/net/usb/mcs7830.c      | 3 +--
 drivers/net/usb/net1080.c      | 3 +--
 drivers/net/usb/plusb.c        | 3 +--
 drivers/net/usb/rndis_host.c   | 3 +--
 drivers/net/usb/sierra_net.c   | 3 +--
 drivers/net/usb/smsc75xx.c     | 3 +--
 drivers/net/usb/smsc75xx.h     | 3 +--
 drivers/net/usb/smsc95xx.c     | 3 +--
 drivers/net/usb/smsc95xx.h     | 3 +--
 drivers/net/usb/usbnet.c       | 3 +--
 drivers/net/usb/zaurus.c       | 3 +--
 25 files changed, 25 insertions(+), 50 deletions(-)

diff --git a/drivers/net/usb/asix.h b/drivers/net/usb/asix.h
index bdaa12d..bad857a 100644
--- a/drivers/net/usb/asix.h
+++ b/drivers/net/usb/asix.h
@@ -16,8 +16,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _ASIX_H
diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 577c72d..5c55f11 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -16,8 +16,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "asix.h"
diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 386a3df..9765a7d 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -16,8 +16,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "asix.h"
diff --git a/drivers/net/usb/ax88172a.c b/drivers/net/usb/ax88172a.c
index 723b387..5f18fcb 100644
--- a/drivers/net/usb/ax88172a.c
+++ b/drivers/net/usb/ax88172a.c
@@ -21,8 +21,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "asix.h"
diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index 8e8d0fc..d6f64da 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -14,8 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/module.h>
diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index df507e6..da6b8a5 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -24,8 +24,7 @@
  * GNU General Public License for more details.
  * 
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  * 
  * Should you need to contact me, the author, you can do so either by
  * e-mail - mail your message to <vojtech@suse.cz>, or by paper mail:
diff --git a/drivers/net/usb/cdc_eem.c b/drivers/net/usb/cdc_eem.c
index 08d55b6..57fd717 100644
--- a/drivers/net/usb/cdc_eem.c
+++ b/drivers/net/usb/cdc_eem.c
@@ -14,8 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/module.h>
diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 2023f3e..4b1c0f3 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -14,8 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 // #define	DEBUG			// error path messages, extra info
diff --git a/drivers/net/usb/cdc_subset.c b/drivers/net/usb/cdc_subset.c
index 0d1fe89..3b2593a 100644
--- a/drivers/net/usb/cdc_subset.c
+++ b/drivers/net/usb/cdc_subset.c
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/module.h>
diff --git a/drivers/net/usb/cx82310_eth.c b/drivers/net/usb/cx82310_eth.c
index 1e207f0..5233e6d 100644
--- a/drivers/net/usb/cx82310_eth.c
+++ b/drivers/net/usb/cx82310_eth.c
@@ -14,8 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/module.h>
diff --git a/drivers/net/usb/gl620a.c b/drivers/net/usb/gl620a.c
index a7e3f4e..3569da1 100644
--- a/drivers/net/usb/gl620a.c
+++ b/drivers/net/usb/gl620a.c
@@ -14,8 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 // #define	DEBUG			// error path messages, extra info
diff --git a/drivers/net/usb/int51x1.c b/drivers/net/usb/int51x1.c
index ace9e74..4ff70b2 100644
--- a/drivers/net/usb/int51x1.c
+++ b/drivers/net/usb/int51x1.c
@@ -20,8 +20,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/module.h>
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index afb117c..250fc21 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -25,8 +25,7 @@
  *     GNU General Public License for more details.
  *
  *     You should have received a copy of the GNU General Public License
- *     along with this program; if not, write to the Free Software Foundation,
- *     Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ *     along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  ****************************************************************/
 
diff --git a/drivers/net/usb/lg-vl600.c b/drivers/net/usb/lg-vl600.c
index 808d650..acfcc32 100644
--- a/drivers/net/usb/lg-vl600.c
+++ b/drivers/net/usb/lg-vl600.c
@@ -15,8 +15,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index 03832d3..aea68bc 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -36,8 +36,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/crc32.h>
diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
index 93e0716..8b2493f 100644
--- a/drivers/net/usb/net1080.c
+++ b/drivers/net/usb/net1080.c
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 // #define	DEBUG			// error path messages, extra info
diff --git a/drivers/net/usb/plusb.c b/drivers/net/usb/plusb.c
index 0fcc8e6..ee705b7 100644
--- a/drivers/net/usb/plusb.c
+++ b/drivers/net/usb/plusb.c
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 // #define	DEBUG			// error path messages, extra info
diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index cc49aac..72aee85 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 #include <linux/module.h>
 #include <linux/init.h>
diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.c
index a79e9d3..a2515887 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -21,8 +21,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #define DRIVER_VERSION "v.2.0"
diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 66ebbac..0217b28 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  *****************************************************************************/
 
diff --git a/drivers/net/usb/smsc75xx.h b/drivers/net/usb/smsc75xx.h
index 67eba39..2c7ea8f 100644
--- a/drivers/net/usb/smsc75xx.h
+++ b/drivers/net/usb/smsc75xx.h
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  *****************************************************************************/
 
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 3f38ba8..96f5eee 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  *****************************************************************************/
 
diff --git a/drivers/net/usb/smsc95xx.h b/drivers/net/usb/smsc95xx.h
index f360ee3..526faa0 100644
--- a/drivers/net/usb/smsc95xx.h
+++ b/drivers/net/usb/smsc95xx.h
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  *****************************************************************************/
 
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 8494bb5..56c175e 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -14,8 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 /*
diff --git a/drivers/net/usb/zaurus.c b/drivers/net/usb/zaurus.c
index 35c9030..25d1e66 100644
--- a/drivers/net/usb/zaurus.c
+++ b/drivers/net/usb/zaurus.c
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 // #define	DEBUG			// error path messages, extra info
-- 
1.8.3.1
