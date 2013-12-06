From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 5/6] net/irda: Fix FSF address in file headers
Date: Fri,  6 Dec 2013 09:13:43 -0800
Message-ID: <1386350024-25308-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386350024-25308-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Samuel Ortiz <samuel@sortiz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54635 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755025Ab3LFROO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 12:14:14 -0500
In-Reply-To: <1386350024-25308-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several files refer to an old address for the Free Software Foundation
in the file header comment.  Resolve by replacing the address with
the URL <http://www.gnu.org/licenses/> so that we do not have to keep
updating the header comments anytime the address changes.

CC: Samuel Ortiz <samuel@sortiz.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 net/irda/af_irda.c                  | 4 +---
 net/irda/discovery.c                | 4 +---
 net/irda/ircomm/ircomm_core.c       | 4 +---
 net/irda/ircomm/ircomm_event.c      | 4 +---
 net/irda/ircomm/ircomm_lmp.c        | 4 +---
 net/irda/ircomm/ircomm_param.c      | 4 +---
 net/irda/ircomm/ircomm_ttp.c        | 4 +---
 net/irda/ircomm/ircomm_tty.c        | 4 +---
 net/irda/ircomm/ircomm_tty_attach.c | 4 +---
 net/irda/ircomm/ircomm_tty_ioctl.c  | 4 +---
 net/irda/irda_device.c              | 4 +---
 net/irda/irlap.c                    | 4 +---
 net/irda/parameters.c               | 4 +---
 net/irda/qos.c                      | 4 +---
 14 files changed, 14 insertions(+), 42 deletions(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index de7db23..73baf9b 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -25,9 +25,7 @@
  *     GNU General Public License for more details.
  *
  *     You should have received a copy of the GNU General Public License
- *     along with this program; if not, write to the Free Software
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  *     Linux-IrDA now supports four different types of IrDA sockets:
  *
diff --git a/net/irda/discovery.c b/net/irda/discovery.c
index b0b56a3..6786e7f 100644
--- a/net/irda/discovery.c
+++ b/net/irda/discovery.c
@@ -24,9 +24,7 @@
  *     GNU General Public License for more details.
  *
  *     You should have received a copy of the GNU General Public License
- *     along with this program; if not, write to the Free Software
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  ********************************************************************/
 
diff --git a/net/irda/ircomm/ircomm_core.c b/net/irda/ircomm/ircomm_core.c
index b797daa..4490a67 100644
--- a/net/irda/ircomm/ircomm_core.c
+++ b/net/irda/ircomm/ircomm_core.c
@@ -23,9 +23,7 @@
  *     GNU General Public License for more details.
  *
  *     You should have received a copy of the GNU General Public License
- *     along with this program; if not, write to the Free Software
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  ********************************************************************/
 
diff --git a/net/irda/ircomm/ircomm_event.c b/net/irda/ircomm/ircomm_event.c
index d78554f..b172c65 100644
--- a/net/irda/ircomm/ircomm_event.c
+++ b/net/irda/ircomm/ircomm_event.c
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
 
diff --git a/net/irda/ircomm/ircomm_lmp.c b/net/irda/ircomm/ircomm_lmp.c
index 3b8095c..6536114 100644
--- a/net/irda/ircomm/ircomm_lmp.c
+++ b/net/irda/ircomm/ircomm_lmp.c
@@ -24,9 +24,7 @@
  *     GNU General Public License for more details.
  *
  *     You should have received a copy of the GNU General Public License
- *     along with this program; if not, write to the Free Software
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  ********************************************************************/
 
diff --git a/net/irda/ircomm/ircomm_param.c b/net/irda/ircomm/ircomm_param.c
index 3089391..f80b1a6 100644
--- a/net/irda/ircomm/ircomm_param.c
+++ b/net/irda/ircomm/ircomm_param.c
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
 
diff --git a/net/irda/ircomm/ircomm_ttp.c b/net/irda/ircomm/ircomm_ttp.c
index 6e6509f..d362d71 100644
--- a/net/irda/ircomm/ircomm_ttp.c
+++ b/net/irda/ircomm/ircomm_ttp.c
@@ -23,9 +23,7 @@
  *     GNU General Public License for more details.
  *
  *     You should have received a copy of the GNU General Public License
- *     along with this program; if not, write to the Free Software
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  ********************************************************************/
 
diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index 41ac7938..2ba8b97 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -24,9 +24,7 @@
  *     GNU General Public License for more details.
  *
  *     You should have received a copy of the GNU General Public License
- *     along with this program; if not, write to the Free Software
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  ********************************************************************/
 
diff --git a/net/irda/ircomm/ircomm_tty_attach.c b/net/irda/ircomm/ircomm_tty_attach.c
index a2a508f..2ee87bf 100644
--- a/net/irda/ircomm/ircomm_tty_attach.c
+++ b/net/irda/ircomm/ircomm_tty_attach.c
@@ -23,9 +23,7 @@
  *     GNU General Public License for more details.
  *
  *     You should have received a copy of the GNU General Public License
- *     along with this program; if not, write to the Free Software
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  ********************************************************************/
 
diff --git a/net/irda/ircomm/ircomm_tty_ioctl.c b/net/irda/ircomm/ircomm_tty_ioctl.c
index b343f50..ce94385 100644
--- a/net/irda/ircomm/ircomm_tty_ioctl.c
+++ b/net/irda/ircomm/ircomm_tty_ioctl.c
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
 
diff --git a/net/irda/irda_device.c b/net/irda/irda_device.c
index 14653b8..365b895 100644
--- a/net/irda/irda_device.c
+++ b/net/irda/irda_device.c
@@ -23,9 +23,7 @@
  *     GNU General Public License for more details.
  *
  *     You should have received a copy of the GNU General Public License
- *     along with this program; if not, write to the Free Software
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  ********************************************************************/
 
diff --git a/net/irda/irlap.c b/net/irda/irlap.c
index 005b424..a778df5 100644
--- a/net/irda/irlap.c
+++ b/net/irda/irlap.c
@@ -23,9 +23,7 @@
  *     GNU General Public License for more details.
  *
  *     You should have received a copy of the GNU General Public License
- *     along with this program; if not, write to the Free Software
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  ********************************************************************/
 
diff --git a/net/irda/parameters.c b/net/irda/parameters.c
index 71cd38c..6d08697 100644
--- a/net/irda/parameters.c
+++ b/net/irda/parameters.c
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
 
diff --git a/net/irda/qos.c b/net/irda/qos.c
index 798ffd9..11a7cc0 100644
--- a/net/irda/qos.c
+++ b/net/irda/qos.c
@@ -24,9 +24,7 @@
  *     GNU General Public License for more details.
  *
  *     You should have received a copy of the GNU General Public License
- *     along with this program; if not, write to the Free Software
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  ********************************************************************/
 
-- 
1.8.3.1
