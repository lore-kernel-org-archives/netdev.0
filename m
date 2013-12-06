From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/6] irda: Fix FSF address in file headers
Date: Fri,  6 Dec 2013 06:28:44 -0800
Message-ID: <1386340128-23397-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386340128-23397-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Samuel Ortiz <samuel@sortiz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29046 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751130Ab3LFO2w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 09:28:52 -0500
In-Reply-To: <1386340128-23397-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several files refer to an old address for the Free Software Foundation
in the file header comment.  Resolve by replacing the address with
the URL <http://www.gnu.org/licenses/> so that we do not have to keep
updating the header comments anytime the address changes.

CC: Samuel Ortiz <samuel@sortiz.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/irda/au1k_ir.c        | 3 +--
 drivers/net/irda/esi-sir.c        | 4 +---
 drivers/net/irda/litelink-sir.c   | 4 +---
 drivers/net/irda/ma600-sir.c      | 4 +---
 drivers/net/irda/old_belkin-sir.c | 4 +---
 drivers/net/irda/smsc-ircc2.c     | 4 +---
 drivers/net/irda/smsc-ircc2.h     | 4 +---
 drivers/net/irda/via-ircc.c       | 3 +--
 drivers/net/irda/via-ircc.h       | 3 +--
 drivers/net/irda/vlsi_ir.c        | 4 +---
 drivers/net/irda/vlsi_ir.h        | 4 +---
 11 files changed, 11 insertions(+), 30 deletions(-)

diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index 7a1f684..5b7a665 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -15,8 +15,7 @@
  *  for more details.
  *
  *  You should have received a copy of the GNU General Public License along
- *  with this program; if not, write to the Free Software Foundation, Inc.,
- *  59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
+ *  with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/init.h>
diff --git a/drivers/net/irda/esi-sir.c b/drivers/net/irda/esi-sir.c
index a908df7..019a3e8 100644
--- a/drivers/net/irda/esi-sir.c
+++ b/drivers/net/irda/esi-sir.c
@@ -25,9 +25,7 @@
  *     GNU General Public License for more details.
  * 
  *     You should have received a copy of the GNU General Public License 
- *     along with this program; if not, write to the Free Software 
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston, 
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licenses/>.
  *     
  ********************************************************************/
 
diff --git a/drivers/net/irda/litelink-sir.c b/drivers/net/irda/litelink-sir.c
index d6d9d2e..6827777 100644
--- a/drivers/net/irda/litelink-sir.c
+++ b/drivers/net/irda/litelink-sir.c
@@ -22,9 +22,7 @@
  *     GNU General Public License for more details.
  * 
  *     You should have received a copy of the GNU General Public License 
- *     along with this program; if not, write to the Free Software 
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston, 
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licenses/>.
  *     
  ********************************************************************/
 
diff --git a/drivers/net/irda/ma600-sir.c b/drivers/net/irda/ma600-sir.c
index e912164..a9a8135 100644
--- a/drivers/net/irda/ma600-sir.c
+++ b/drivers/net/irda/ma600-sir.c
@@ -25,9 +25,7 @@
  *     GNU General Public License for more details.
  * 
  *     You should have received a copy of the GNU General Public License 
- *     along with this program; if not, write to the Free Software 
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston, 
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licenses/>.
  *     
  ********************************************************************/
 
diff --git a/drivers/net/irda/old_belkin-sir.c b/drivers/net/irda/old_belkin-sir.c
index 75714bc..f237136 100644
--- a/drivers/net/irda/old_belkin-sir.c
+++ b/drivers/net/irda/old_belkin-sir.c
@@ -22,9 +22,7 @@
  *     GNU General Public License for more details.
  * 
  *     You should have received a copy of the GNU General Public License 
- *     along with this program; if not, write to the Free Software 
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston, 
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licenses/>.
  *     
  ********************************************************************/
 
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 0dcdf15..2821204 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -34,9 +34,7 @@
  *     GNU General Public License for more details.
  *
  *     You should have received a copy of the GNU General Public License
- *     along with this program; if not, write to the Free Software
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  ********************************************************************/
 
diff --git a/drivers/net/irda/smsc-ircc2.h b/drivers/net/irda/smsc-ircc2.h
index 317b7fd..4829fa2 100644
--- a/drivers/net/irda/smsc-ircc2.h
+++ b/drivers/net/irda/smsc-ircc2.h
@@ -25,9 +25,7 @@
  *     GNU General Public License for more details.
  *
  *     You should have received a copy of the GNU General Public License
- *     along with this program; if not, write to the Free Software
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  ********************************************************************/
 
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 9abaec2..26cb45d 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -17,8 +17,7 @@ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 See the GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with
-this program; if not, write to the Free Software Foundation, Inc.,
-59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+this program; if not, see <http://www.gnu.org/licenses/>.
 
 F01 Oct/02/02: Modify code for V0.11(move out back to back transfer)
 F02 Oct/28/02: Add SB device ID for 3147 and 3177.
diff --git a/drivers/net/irda/via-ircc.h b/drivers/net/irda/via-ircc.h
index f903a6a..7ce820e 100644
--- a/drivers/net/irda/via-ircc.h
+++ b/drivers/net/irda/via-ircc.h
@@ -18,8 +18,7 @@ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 See the GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with
-this program; if not, write to the Free Software Foundation, Inc.,
-59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+this program; if not, see <http://www.gnu.org/licenses/>.
 
  * Comment:
  * jul/08/2002 : Rx buffer length should use Rx ring ptr.	
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index c5bd58b..cc9b866 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -15,9 +15,7 @@
  *	GNU General Public License for more details.
  *
  *	You should have received a copy of the GNU General Public License 
- *	along with this program; if not, write to the Free Software 
- *	Foundation, Inc., 59 Temple Place, Suite 330, Boston, 
- *	MA 02111-1307 USA
+ *	along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  ********************************************************************/
 
diff --git a/drivers/net/irda/vlsi_ir.h b/drivers/net/irda/vlsi_ir.h
index a076eb1..5639920 100644
--- a/drivers/net/irda/vlsi_ir.h
+++ b/drivers/net/irda/vlsi_ir.h
@@ -18,9 +18,7 @@
  *	GNU General Public License for more details.
  *
  *	You should have received a copy of the GNU General Public License 
- *	along with this program; if not, write to the Free Software 
- *	Foundation, Inc., 59 Temple Place, Suite 330, Boston, 
- *	MA 02111-1307 USA
+ *	along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  ********************************************************************/
 
-- 
1.8.3.1
