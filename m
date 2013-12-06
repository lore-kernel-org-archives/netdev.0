From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/6] netlabel: Fix FSF address in file headers
Date: Fri,  6 Dec 2013 09:13:41 -0800
Message-ID: <1386350024-25308-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386350024-25308-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Paul Moore <paul@paul-moore.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54624 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754166Ab3LFRON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 12:14:13 -0500
In-Reply-To: <1386350024-25308-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several files refer to an old address for the Free Software Foundation
in the file header comment.  Resolve by replacing the address with
the URL <http://www.gnu.org/licenses/> so that we do not have to keep
updating the header comments anytime the address changes.

CC: Paul Moore <paul@paul-moore.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 net/netlabel/netlabel_addrlist.c   | 3 +--
 net/netlabel/netlabel_addrlist.h   | 3 +--
 net/netlabel/netlabel_cipso_v4.c   | 3 +--
 net/netlabel/netlabel_cipso_v4.h   | 3 +--
 net/netlabel/netlabel_domainhash.c | 3 +--
 net/netlabel/netlabel_domainhash.h | 3 +--
 net/netlabel/netlabel_kapi.c       | 3 +--
 net/netlabel/netlabel_mgmt.c       | 3 +--
 net/netlabel/netlabel_mgmt.h       | 3 +--
 net/netlabel/netlabel_unlabeled.c  | 3 +--
 net/netlabel/netlabel_unlabeled.h  | 3 +--
 net/netlabel/netlabel_user.c       | 3 +--
 net/netlabel/netlabel_user.h       | 3 +--
 13 files changed, 13 insertions(+), 26 deletions(-)

diff --git a/net/netlabel/netlabel_addrlist.c b/net/netlabel/netlabel_addrlist.c
index 6f17013..d0a3acf 100644
--- a/net/netlabel/netlabel_addrlist.c
+++ b/net/netlabel/netlabel_addrlist.c
@@ -24,8 +24,7 @@
  * the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program;  if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program;  if not, see <http://www.gnu.org/licenses/>.
  *
  */
 
diff --git a/net/netlabel/netlabel_addrlist.h b/net/netlabel/netlabel_addrlist.h
index a1287ce..d0f38bc 100644
--- a/net/netlabel/netlabel_addrlist.h
+++ b/net/netlabel/netlabel_addrlist.h
@@ -24,8 +24,7 @@
  * the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program;  if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program;  if not, see <http://www.gnu.org/licenses/>.
  *
  */
 
diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
index 69345ce..c2f2a53 100644
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -23,8 +23,7 @@
  * the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program;  if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program;  if not, see <http://www.gnu.org/licenses/>.
  *
  */
 
diff --git a/net/netlabel/netlabel_cipso_v4.h b/net/netlabel/netlabel_cipso_v4.h
index d24d774..8758268 100644
--- a/net/netlabel/netlabel_cipso_v4.h
+++ b/net/netlabel/netlabel_cipso_v4.h
@@ -23,8 +23,7 @@
  * the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program;  if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program;  if not, see <http://www.gnu.org/licenses/>.
  *
  */
 
diff --git a/net/netlabel/netlabel_domainhash.c b/net/netlabel/netlabel_domainhash.c
index 85d842e..f0cb92f 100644
--- a/net/netlabel/netlabel_domainhash.c
+++ b/net/netlabel/netlabel_domainhash.c
@@ -24,8 +24,7 @@
  * the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program;  if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program;  if not, see <http://www.gnu.org/licenses/>.
  *
  */
 
diff --git a/net/netlabel/netlabel_domainhash.h b/net/netlabel/netlabel_domainhash.h
index b9be0ee..680caf4 100644
--- a/net/netlabel/netlabel_domainhash.h
+++ b/net/netlabel/netlabel_domainhash.h
@@ -24,8 +24,7 @@
  * the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program;  if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program;  if not, see <http://www.gnu.org/licenses/>.
  *
  */
 
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index dce1beb..3045a96 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -23,8 +23,7 @@
  * the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program;  if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program;  if not, see <http://www.gnu.org/licenses/>.
  *
  */
 
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index 8ef83ee..e66e977 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -23,8 +23,7 @@
  * the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program;  if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program;  if not, see <http://www.gnu.org/licenses/>.
  *
  */
 
diff --git a/net/netlabel/netlabel_mgmt.h b/net/netlabel/netlabel_mgmt.h
index 5a9f31c..8b6e1ab 100644
--- a/net/netlabel/netlabel_mgmt.h
+++ b/net/netlabel/netlabel_mgmt.h
@@ -23,8 +23,7 @@
  * the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program;  if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program;  if not, see <http://www.gnu.org/licenses/>.
  *
  */
 
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 43817d7..78a63c1 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -23,8 +23,7 @@
  * the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program;  if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program;  if not, see <http://www.gnu.org/licenses/>.
  *
  */
 
diff --git a/net/netlabel/netlabel_unlabeled.h b/net/netlabel/netlabel_unlabeled.h
index 700af49..3a9e5dc 100644
--- a/net/netlabel/netlabel_unlabeled.h
+++ b/net/netlabel/netlabel_unlabeled.h
@@ -23,8 +23,7 @@
  * the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program;  if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program;  if not, see <http://www.gnu.org/licenses/>.
  *
  */
 
diff --git a/net/netlabel/netlabel_user.c b/net/netlabel/netlabel_user.c
index 9650c4a..1e779bb 100644
--- a/net/netlabel/netlabel_user.c
+++ b/net/netlabel/netlabel_user.c
@@ -23,8 +23,7 @@
  * the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program;  if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program;  if not, see <http://www.gnu.org/licenses/>.
  *
  */
 
diff --git a/net/netlabel/netlabel_user.h b/net/netlabel/netlabel_user.h
index 8196978..4a397cd 100644
--- a/net/netlabel/netlabel_user.h
+++ b/net/netlabel/netlabel_user.h
@@ -23,8 +23,7 @@
  * the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program;  if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program;  if not, see <http://www.gnu.org/licenses/>.
  *
  */
 
-- 
1.8.3.1
