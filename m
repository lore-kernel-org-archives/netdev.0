From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/6] netfilter: Fix FSF address in file headers
Date: Fri,  6 Dec 2013 09:13:42 -0800
Message-ID: <1386350024-25308-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386350024-25308-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, netfilter@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54612 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754989Ab3LFROO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 12:14:14 -0500
In-Reply-To: <1386350024-25308-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several files refer to an old address for the Free Software Foundation
in the file header comment.  Resolve by replacing the address with
the URL <http://www.gnu.org/licenses/> so that we do not have to keep
updating the header comments anytime the address changes.

CC: netfilter@vger.kernel.org
CC: Pablo Neira Ayuso <pablo@netfilter.org>
CC: Patrick McHardy <kaber@trash.net>
CC: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/uapi/linux/netfilter/xt_osf.h | 3 +--
 net/bridge/netfilter/ebt_vlan.c       | 3 +--
 net/netfilter/ipvs/ip_vs_nfct.c       | 3 +--
 net/netfilter/xt_connmark.c           | 3 +--
 net/netfilter/xt_osf.c                | 3 +--
 5 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/include/uapi/linux/netfilter/xt_osf.h b/include/uapi/linux/netfilter/xt_osf.h
index 18afa49..5d66cae 100644
--- a/include/uapi/linux/netfilter/xt_osf.h
+++ b/include/uapi/linux/netfilter/xt_osf.h
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _XT_OSF_H
diff --git a/net/bridge/netfilter/ebt_vlan.c b/net/bridge/netfilter/ebt_vlan.c
index eae67bf..8d3f8c7 100644
--- a/net/bridge/netfilter/ebt_vlan.c
+++ b/net/bridge/netfilter/ebt_vlan.c
@@ -14,8 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/if_ether.h>
diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
index c8beafd..d5f4151 100644
--- a/net/netfilter/ipvs/ip_vs_nfct.c
+++ b/net/netfilter/ipvs/ip_vs_nfct.c
@@ -19,8 +19,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  *
  * Authors:
diff --git a/net/netfilter/xt_connmark.c b/net/netfilter/xt_connmark.c
index 7278145..69f78e9 100644
--- a/net/netfilter/xt_connmark.c
+++ b/net/netfilter/xt_connmark.c
@@ -17,8 +17,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/module.h>
diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 647d989..7174611 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
-- 
1.8.3.1
