From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 6/6] sctp: Fix FSF address in file headers
Date: Fri,  6 Dec 2013 06:28:48 -0800
Message-ID: <1386340128-23397-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386340128-23397-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29046 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755901Ab3LFO25 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 09:28:57 -0500
In-Reply-To: <1386340128-23397-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several files refer to an old address for the Free Software Foundation
in the file header comment.  Resolve by replacing the address with
the URL <http://www.gnu.org/licenses/> so that we do not have to keep
updating the header comments anytime the address changes.

CC: Vlad Yasevich <vyasevich@gmail.com>
CC: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/sctp.h        | 5 ++---
 include/net/sctp/sctp.h     | 5 ++---
 include/net/sctp/sm.h       | 5 ++---
 include/net/sctp/structs.h  | 5 ++---
 include/net/sctp/tsnmap.h   | 5 ++---
 include/net/sctp/ulpevent.h | 5 ++---
 include/net/sctp/ulpqueue.h | 5 ++---
 include/uapi/linux/sctp.h   | 5 ++---
 net/sctp/associola.c        | 5 ++---
 net/sctp/auth.c             | 5 ++---
 net/sctp/bind_addr.c        | 5 ++---
 net/sctp/chunk.c            | 5 ++---
 net/sctp/command.c          | 5 ++---
 net/sctp/debug.c            | 5 ++---
 net/sctp/endpointola.c      | 5 ++---
 net/sctp/input.c            | 5 ++---
 net/sctp/inqueue.c          | 5 ++---
 net/sctp/ipv6.c             | 5 ++---
 net/sctp/objcnt.c           | 5 ++---
 net/sctp/output.c           | 5 ++---
 net/sctp/outqueue.c         | 5 ++---
 net/sctp/primitive.c        | 5 ++---
 net/sctp/proc.c             | 5 ++---
 net/sctp/protocol.c         | 5 ++---
 net/sctp/sm_make_chunk.c    | 5 ++---
 net/sctp/sm_sideeffect.c    | 5 ++---
 net/sctp/sm_statefuns.c     | 5 ++---
 net/sctp/sm_statetable.c    | 5 ++---
 net/sctp/socket.c           | 5 ++---
 net/sctp/ssnmap.c           | 5 ++---
 net/sctp/sysctl.c           | 5 ++---
 net/sctp/transport.c        | 5 ++---
 net/sctp/tsnmap.c           | 5 ++---
 net/sctp/ulpevent.c         | 5 ++---
 net/sctp/ulpqueue.c         | 5 ++---
 35 files changed, 70 insertions(+), 105 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 3bfe8d6..c4c5eba 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -23,9 +23,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index c5fe806..610a8c8 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -21,9 +21,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 4ef75af..7f4eeb3 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -21,9 +21,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email addresses:
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index ea0ca5f..e416d6a 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -19,9 +19,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email addresses:
diff --git a/include/net/sctp/tsnmap.h b/include/net/sctp/tsnmap.h
index 54bbbe5..31b8dba 100644
--- a/include/net/sctp/tsnmap.h
+++ b/include/net/sctp/tsnmap.h
@@ -22,9 +22,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
index 27b9f5c..daacb32 100644
--- a/include/net/sctp/ulpevent.h
+++ b/include/net/sctp/ulpevent.h
@@ -25,9 +25,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/include/net/sctp/ulpqueue.h b/include/net/sctp/ulpqueue.h
index b0cf5d5..e0dce07 100644
--- a/include/net/sctp/ulpqueue.h
+++ b/include/net/sctp/ulpqueue.h
@@ -24,9 +24,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email addresses:
diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index ca451e9..266022a 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -22,9 +22,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 68a27f9..66882a2 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -22,9 +22,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index 46b5977..5c9f64c 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -16,9 +16,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index 077bb07..871cdf9 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -21,9 +21,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index f2044fc..5573e42 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -18,9 +18,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/command.c b/net/sctp/command.c
index 3d9a9ff..dd73758 100644
--- a/net/sctp/command.c
+++ b/net/sctp/command.c
@@ -19,9 +19,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/debug.c b/net/sctp/debug.c
index e89015d..95d7b15 100644
--- a/net/sctp/debug.c
+++ b/net/sctp/debug.c
@@ -22,9 +22,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 09b8daa..6ffb6c1 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -23,9 +23,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 98b69bb..6603853 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -23,9 +23,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
index 5856932..4de12af 100644
--- a/net/sctp/inqueue.c
+++ b/net/sctp/inqueue.c
@@ -24,9 +24,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 7567e6f..32db816 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -21,9 +21,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/objcnt.c b/net/sctp/objcnt.c
index 647396b..0c28e8a 100644
--- a/net/sctp/objcnt.c
+++ b/net/sctp/objcnt.c
@@ -20,9 +20,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 0e2644d..6371337 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -20,9 +20,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index f51ba98..b6b09f3 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -22,9 +22,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/primitive.c b/net/sctp/primitive.c
index ce1ffd8..ab8d9f9 100644
--- a/net/sctp/primitive.c
+++ b/net/sctp/primitive.c
@@ -23,9 +23,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 0c06421..de32e14 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -16,9 +16,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 5e17092..19bd4c5 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -23,9 +23,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index fe69032..d9aaf96 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -23,9 +23,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 1a6eef3..02b7ad1 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -22,9 +22,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index dfe3f36..dd0eba9 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -22,9 +22,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index c5999b2..a4f1743 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -22,9 +22,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 72046b9..191cd92 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -28,9 +28,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/ssnmap.c b/net/sctp/ssnmap.c
index 6007124..b9c8521 100644
--- a/net/sctp/ssnmap.c
+++ b/net/sctp/ssnmap.c
@@ -18,9 +18,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 6b36561..80b17b5 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -19,9 +19,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index efc46ff..d0810dc 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -24,9 +24,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/tsnmap.c b/net/sctp/tsnmap.c
index fbda200..7635f9f 100644
--- a/net/sctp/tsnmap.c
+++ b/net/sctp/tsnmap.c
@@ -21,9 +21,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 81089ed..85c6465 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -22,9 +22,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 1c1484e..a674700 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -21,9 +21,8 @@
  * See the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, write to
- * the Free Software Foundation, 59 Temple Place - Suite 330,
- * Boston, MA 02111-1307, USA.
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
-- 
1.8.3.1
