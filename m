From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/6] ipv4/ipv6: Fix FSF address in file headers
Date: Fri,  6 Dec 2013 09:13:39 -0800
Message-ID: <1386350024-25308-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54612 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752948Ab3LFROM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 12:14:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several files refer to an old address for the Free Software Foundation
in the file header comment.  Resolve by replacing the address with
the URL <http://www.gnu.org/licenses/> so that we do not have to keep
updating the header comments anytime the address changes.

CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
CC: James Morris <jmorris@namei.org>
CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
CC: Patrick McHardy <kaber@trash.net>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 net/ipv4/cipso_ipv4.c                  | 3 +--
 net/ipv4/netfilter/nf_nat_snmp_basic.c | 3 +--
 net/ipv6/ah6.c                         | 3 +--
 net/ipv6/esp6.c                        | 3 +--
 net/ipv6/ipcomp6.c                     | 3 +--
 net/ipv6/mip6.c                        | 3 +--
 net/ipv6/tunnel6.c                     | 3 +--
 net/ipv6/xfrm6_mode_ro.c               | 3 +--
 net/ipv6/xfrm6_tunnel.c                | 3 +--
 9 files changed, 9 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 667c1d4..4b59b6e 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -31,8 +31,7 @@
  * the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program;  if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ * along with this program;  if not, see <http://www.gnu.org/licenses/>.
  *
  */
 
diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index 5f011cc..61a9422 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -34,8 +34,7 @@
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * Author: James Morris <jmorris@intercode.com.au>
  *
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 82e1da3..81e496a 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -12,8 +12,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * Authors
  *
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index b8719df..6eef8a7 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -12,8 +12,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * Authors
  *
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index ce507d9..da9becb 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -16,8 +16,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 /*
  * [Memo]
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 9ac01dc..db9b6cb 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 /*
  * Authors:
diff --git a/net/ipv6/tunnel6.c b/net/ipv6/tunnel6.c
index 4b0f50d..2c4e4c5 100644
--- a/net/ipv6/tunnel6.c
+++ b/net/ipv6/tunnel6.c
@@ -12,8 +12,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * Authors	Mitsuru KANDA  <mk@linux-ipv6.org>
  * 		YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
diff --git a/net/ipv6/xfrm6_mode_ro.c b/net/ipv6/xfrm6_mode_ro.c
index 63d5d49..0e01590 100644
--- a/net/ipv6/xfrm6_mode_ro.c
+++ b/net/ipv6/xfrm6_mode_ro.c
@@ -15,8 +15,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 /*
  * Authors:
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index de2bcfa..1c66465 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -12,8 +12,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * Authors	Mitsuru KANDA  <mk@linux-ipv6.org>
  * 		YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
-- 
1.8.3.1
