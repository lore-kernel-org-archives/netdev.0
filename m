From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 6/6] net/*: Fix FSF address in file headers
Date: Fri,  6 Dec 2013 09:13:44 -0800
Message-ID: <1386350024-25308-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386350024-25308-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54624 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755519Ab3LFROO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 12:14:14 -0500
In-Reply-To: <1386350024-25308-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several files refer to an old address for the Free Software Foundation
in the file header comment.  Resolve by replacing the address with
the URL <http://www.gnu.org/licenses/> so that we do not have to keep
updating the header comments anytime the address changes.

CC: John Fastabend <john.r.fastabend@intel.com>
CC: Alex Duyck <alexander.h.duyck@intel.com>
CC: Marcel Holtmann <marcel@holtmann.org>
CC: Gustavo Padovan <gustavo@padovan.org>
CC: Johan Hedberg <johan.hedberg@gmail.com>
CC: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 net/bluetooth/bnep/bnep.h    | 3 +--
 net/dcb/dcbevent.c           | 3 +--
 net/dcb/dcbnl.c              | 3 +--
 net/dns_resolver/dns_key.c   | 3 +--
 net/dns_resolver/dns_query.c | 3 +--
 net/dns_resolver/internal.h  | 3 +--
 net/sched/act_skbedit.c      | 3 +--
 net/sched/sch_multiq.c       | 3 +--
 8 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/net/bluetooth/bnep/bnep.h b/net/bluetooth/bnep/bnep.h
index e7ee531..5a5b16f 100644
--- a/net/bluetooth/bnep/bnep.h
+++ b/net/bluetooth/bnep/bnep.h
@@ -12,8 +12,7 @@
   GNU General Public License for more details.
 
   You should have received a copy of the GNU General Public License
-  along with this program; if not, write to the Free Software
-  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
+  along with this program; if not, see <http://www.gnu.org/licenses/>.
 */
 
 #ifndef _BNEP_H
diff --git a/net/dcb/dcbevent.c b/net/dcb/dcbevent.c
index 4f72fc4..a520d80 100644
--- a/net/dcb/dcbevent.c
+++ b/net/dcb/dcbevent.c
@@ -11,8 +11,7 @@
  * more details.
  *
  * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
- * Place - Suite 330, Boston, MA 02111-1307 USA.
+ * this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * Author: John Fastabend <john.r.fastabend@intel.com>
  */
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 40d5829..66fbe19 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -11,8 +11,7 @@
  * more details.
  *
  * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
- * Place - Suite 330, Boston, MA 02111-1307 USA.
+ * this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * Author: Lucy Liu <lucy.liu@intel.com>
  */
diff --git a/net/dns_resolver/dns_key.c b/net/dns_resolver/dns_key.c
index f347a2c..bf85843 100644
--- a/net/dns_resolver/dns_key.c
+++ b/net/dns_resolver/dns_key.c
@@ -19,8 +19,7 @@
  *   the GNU Lesser General Public License for more details.
  *
  *   You should have received a copy of the GNU Lesser General Public License
- *   along with this library; if not, write to the Free Software
- *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *   along with this library; if not, see <http://www.gnu.org/licenses/>.
  */
 #include <linux/module.h>
 #include <linux/moduleparam.h>
diff --git a/net/dns_resolver/dns_query.c b/net/dns_resolver/dns_query.c
index c32be29..e7b6d53 100644
--- a/net/dns_resolver/dns_query.c
+++ b/net/dns_resolver/dns_query.c
@@ -32,8 +32,7 @@
  *   the GNU Lesser General Public License for more details.
  *
  *   You should have received a copy of the GNU Lesser General Public License
- *   along with this library; if not, write to the Free Software
- *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *   along with this library; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/module.h>
diff --git a/net/dns_resolver/internal.h b/net/dns_resolver/internal.h
index 17c7886..7af1ed3 100644
--- a/net/dns_resolver/internal.h
+++ b/net/dns_resolver/internal.h
@@ -15,8 +15,7 @@
  *   the GNU Lesser General Public License for more details.
  *
  *   You should have received a copy of the GNU Lesser General Public License
- *   along with this library; if not, write to the Free Software
- *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *   along with this library; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/compiler.h>
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 35ea643..cf20add 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -11,8 +11,7 @@
  * more details.
  *
  * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
- * Place - Suite 330, Boston, MA 02111-1307 USA.
+ * this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * Author: Alexander Duyck <alexander.h.duyck@intel.com>
  */
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 2a2b096..afb050a 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -11,8 +11,7 @@
  * more details.
  *
  * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
- * Place - Suite 330, Boston, MA 02111-1307 USA.
+ * this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * Author: Alexander Duyck <alexander.h.duyck@intel.com>
  */
-- 
1.8.3.1
