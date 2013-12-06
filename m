From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/6] include/net/: Fix FSF address in file headers
Date: Fri,  6 Dec 2013 09:13:40 -0800
Message-ID: <1386350024-25308-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386350024-25308-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54612 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753940Ab3LFRON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 12:14:13 -0500
In-Reply-To: <1386350024-25308-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several files refer to an old address for the Free Software Foundation
in the file header comment.  Resolve by replacing the address with
the URL <http://www.gnu.org/licenses/> so that we do not have to keep
updating the header comments anytime the address changes.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/net/cipso_ipv4.h             | 3 +--
 include/net/dcbevent.h               | 3 +--
 include/net/dcbnl.h                  | 3 +--
 include/net/irda/discovery.h         | 4 +---
 include/net/irda/ircomm_core.h       | 4 +---
 include/net/irda/ircomm_event.h      | 4 +---
 include/net/irda/ircomm_lmp.h        | 4 +---
 include/net/irda/ircomm_param.h      | 4 +---
 include/net/irda/ircomm_ttp.h        | 4 +---
 include/net/irda/ircomm_tty.h        | 4 +---
 include/net/irda/ircomm_tty_attach.h | 4 +---
 include/net/irda/irda_device.h       | 4 +---
 include/net/irda/irlap_event.h       | 4 +---
 include/net/irda/irlap_frame.h       | 4 +---
 include/net/irda/parameters.h        | 4 +---
 include/net/irda/qos.h               | 4 +---
 include/net/mip6.h                   | 3 +--
 include/net/netlabel.h               | 3 +--
 include/net/nfc/hci.h                | 4 +---
 include/net/nfc/llc.h                | 4 +---
 include/net/nfc/nci.h                | 3 +--
 include/net/nfc/nci_core.h           | 3 +--
 include/net/nfc/nfc.h                | 4 +---
 include/net/sctp/auth.h              | 5 ++---
 include/net/sctp/checksum.h          | 5 ++---
 include/net/sctp/command.h           | 5 ++---
 include/net/sctp/constants.h         | 5 ++---
 include/net/tc_act/tc_skbedit.h      | 3 +--
 28 files changed, 32 insertions(+), 76 deletions(-)

diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h
index a8c2ef6..2179d07 100644
--- a/include/net/cipso_ipv4.h
+++ b/include/net/cipso_ipv4.h
@@ -26,8 +26,7 @@
  * the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program;  if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307=
 USA
+ * along with this program;  if not, see <http://www.gnu.org/licenses/=
>.
  *
  */
=20
diff --git a/include/net/dcbevent.h b/include/net/dcbevent.h
index d2f3041..aec07c8 100644
--- a/include/net/dcbevent.h
+++ b/include/net/dcbevent.h
@@ -11,8 +11,7 @@
  * more details.
  *
  * You should have received a copy of the GNU General Public License a=
long with
- * this program; if not, write to the Free Software Foundation, Inc., =
59 Temple
- * Place - Suite 330, Boston, MA 02111-1307 USA.
+ * this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * Author: John Fastabend <john.r.fastabend@intel.com>
  */
diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index fc5d5dc..a975edf 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -11,8 +11,7 @@
  * more details.
  *
  * You should have received a copy of the GNU General Public License a=
long with
- * this program; if not, write to the Free Software Foundation, Inc., =
59 Temple
- * Place - Suite 330, Boston, MA 02111-1307 USA.
+ * this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * Author: Lucy Liu <lucy.liu@intel.com>
  */
diff --git a/include/net/irda/discovery.h b/include/net/irda/discovery.=
h
index 0ce9339..63ae325 100644
--- a/include/net/irda/discovery.h
+++ b/include/net/irda/discovery.h
@@ -23,9 +23,7 @@
  *     GNU General Public License for more details.
  *=20
  *     You should have received a copy of the GNU General Public Licen=
se=20
- *     along with this program; if not, write to the Free Software=20
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,=20
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licens=
es/>.
  *    =20
  ********************************************************************/
=20
diff --git a/include/net/irda/ircomm_core.h b/include/net/irda/ircomm_c=
ore.h
index 69b610a..2a580ce 100644
--- a/include/net/irda/ircomm_core.h
+++ b/include/net/irda/ircomm_core.h
@@ -22,9 +22,7 @@
  *     GNU General Public License for more details.
  *=20
  *     You should have received a copy of the GNU General Public Licen=
se=20
- *     along with this program; if not, write to the Free Software=20
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,=20
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licens=
es/>.
  *    =20
  ********************************************************************/
=20
diff --git a/include/net/irda/ircomm_event.h b/include/net/irda/ircomm_=
event.h
index bc0c6f3..5bbc329 100644
--- a/include/net/irda/ircomm_event.h
+++ b/include/net/irda/ircomm_event.h
@@ -22,9 +22,7 @@
  *     GNU General Public License for more details.
  *=20
  *     You should have received a copy of the GNU General Public Licen=
se=20
- *     along with this program; if not, write to the Free Software=20
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,=20
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licens=
es/>.
  *    =20
  ********************************************************************/
=20
diff --git a/include/net/irda/ircomm_lmp.h b/include/net/irda/ircomm_lm=
p.h
index ae02106..5042a50 100644
--- a/include/net/irda/ircomm_lmp.h
+++ b/include/net/irda/ircomm_lmp.h
@@ -22,9 +22,7 @@
  *     GNU General Public License for more details.
  *=20
  *     You should have received a copy of the GNU General Public Licen=
se=20
- *     along with this program; if not, write to the Free Software=20
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,=20
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licens=
es/>.
  *    =20
  ********************************************************************/
=20
diff --git a/include/net/irda/ircomm_param.h b/include/net/irda/ircomm_=
param.h
index e667880..1f67432 100644
--- a/include/net/irda/ircomm_param.h
+++ b/include/net/irda/ircomm_param.h
@@ -22,9 +22,7 @@
  *     GNU General Public License for more details.
  *=20
  *     You should have received a copy of the GNU General Public Licen=
se=20
- *     along with this program; if not, write to the Free Software=20
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,=20
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licens=
es/>.
  *    =20
  ********************************************************************/
=20
diff --git a/include/net/irda/ircomm_ttp.h b/include/net/irda/ircomm_tt=
p.h
index 403081e..c562728 100644
--- a/include/net/irda/ircomm_ttp.h
+++ b/include/net/irda/ircomm_ttp.h
@@ -22,9 +22,7 @@
  *     GNU General Public License for more details.
  *=20
  *     You should have received a copy of the GNU General Public Licen=
se=20
- *     along with this program; if not, write to the Free Software=20
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,=20
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licens=
es/>.
  *    =20
  ********************************************************************/
=20
diff --git a/include/net/irda/ircomm_tty.h b/include/net/irda/ircomm_tt=
y.h
index 0224402..8d4f588 100644
--- a/include/net/irda/ircomm_tty.h
+++ b/include/net/irda/ircomm_tty.h
@@ -22,9 +22,7 @@
  *     GNU General Public License for more details.
  *=20
  *     You should have received a copy of the GNU General Public Licen=
se=20
- *     along with this program; if not, write to the Free Software=20
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,=20
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licens=
es/>.
  *    =20
  ********************************************************************/
=20
diff --git a/include/net/irda/ircomm_tty_attach.h b/include/net/irda/ir=
comm_tty_attach.h
index 0a63bbb..20dcbdf 100644
--- a/include/net/irda/ircomm_tty_attach.h
+++ b/include/net/irda/ircomm_tty_attach.h
@@ -22,9 +22,7 @@
  *     GNU General Public License for more details.
  *=20
  *     You should have received a copy of the GNU General Public Licen=
se=20
- *     along with this program; if not, write to the Free Software=20
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,=20
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licens=
es/>.
  *    =20
  ********************************************************************/
=20
diff --git a/include/net/irda/irda_device.h b/include/net/irda/irda_dev=
ice.h
index 1141747..664bf81 100644
--- a/include/net/irda/irda_device.h
+++ b/include/net/irda/irda_device.h
@@ -24,9 +24,7 @@
  *     GNU General Public License for more details.
  *=20
  *     You should have received a copy of the GNU General Public Licen=
se=20
- *     along with this program; if not, write to the Free Software=20
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,=20
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licens=
es/>.
  *    =20
  ********************************************************************/
=20
diff --git a/include/net/irda/irlap_event.h b/include/net/irda/irlap_ev=
ent.h
index f9d88da..e4325fe 100644
--- a/include/net/irda/irlap_event.h
+++ b/include/net/irda/irlap_event.h
@@ -25,9 +25,7 @@
  *     GNU General Public License for more details.
  *=20
  *     You should have received a copy of the GNU General Public Licen=
se=20
- *     along with this program; if not, write to the Free Software=20
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,=20
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licens=
es/>.
  *    =20
  ********************************************************************/
=20
diff --git a/include/net/irda/irlap_frame.h b/include/net/irda/irlap_fr=
ame.h
index 57173ae..cbc12a9 100644
--- a/include/net/irda/irlap_frame.h
+++ b/include/net/irda/irlap_frame.h
@@ -24,9 +24,7 @@
  *     GNU General Public License for more details.
  *=20
  *     You should have received a copy of the GNU General Public Licen=
se=20
- *     along with this program; if not, write to the Free Software=20
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,=20
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licens=
es/>.
  *    =20
  ********************************************************************/
=20
diff --git a/include/net/irda/parameters.h b/include/net/irda/parameter=
s.h
index c0d9388..42713c9 100644
--- a/include/net/irda/parameters.h
+++ b/include/net/irda/parameters.h
@@ -22,9 +22,7 @@
  *     GNU General Public License for more details.
  *=20
  *     You should have received a copy of the GNU General Public Licen=
se=20
- *     along with this program; if not, write to the Free Software=20
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,=20
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licens=
es/>.
  *
  *     Michel D=C3=A4nzer <daenzer@debian.org>, 10/2001
  *     - simplify irda_pv_t to avoid endianness issues
diff --git a/include/net/irda/qos.h b/include/net/irda/qos.h
index cc577dc..05a5a24 100644
--- a/include/net/irda/qos.h
+++ b/include/net/irda/qos.h
@@ -22,9 +22,7 @@
  *     GNU General Public License for more details.
  *=20
  *     You should have received a copy of the GNU General Public Licen=
se=20
- *     along with this program; if not, write to the Free Software=20
- *     Foundation, Inc., 59 Temple Place, Suite 330, Boston,=20
- *     MA 02111-1307 USA
+ *     along with this program; if not, see <http://www.gnu.org/licens=
es/>.
  *    =20
  ********************************************************************/
=20
diff --git a/include/net/mip6.h b/include/net/mip6.h
index 26ba99b..0386b61 100644
--- a/include/net/mip6.h
+++ b/include/net/mip6.h
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-130=
7  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>=
=2E
  */
 /*
  * Authors:
diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index 2c95d55..24948be 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -22,8 +22,7 @@
  * the GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program;  if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307=
 USA
+ * along with this program;  if not, see <http://www.gnu.org/licenses/=
>.
  *
  */
=20
diff --git a/include/net/nfc/hci.h b/include/net/nfc/hci.h
index 2eca296..03c4650 100644
--- a/include/net/nfc/hci.h
+++ b/include/net/nfc/hci.h
@@ -12,9 +12,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the
- * Free Software Foundation, Inc.,
- * 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>=
=2E
  */
=20
 #ifndef __NET_HCI_H
diff --git a/include/net/nfc/llc.h b/include/net/nfc/llc.h
index 400ab7a..c25fbde 100644
--- a/include/net/nfc/llc.h
+++ b/include/net/nfc/llc.h
@@ -13,9 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the
- * Free Software Foundation, Inc.,
- * 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>=
=2E
  */
=20
 #ifndef __NFC_LLC_H_
diff --git a/include/net/nfc/nci.h b/include/net/nfc/nci.h
index e5aa5ac..fbfa4e4 100644
--- a/include/net/nfc/nci.h
+++ b/include/net/nfc/nci.h
@@ -20,8 +20,7 @@
  *  GNU General Public License for more details.
  *
  *  You should have received a copy of the GNU General Public License
- *  along with this program; if not, write to the Free Software
- *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-13=
07  USA
+ *  along with this program; if not, see <http://www.gnu.org/licenses/=
>.
  *
  */
=20
diff --git a/include/net/nfc/nci_core.h b/include/net/nfc/nci_core.h
index 6126f1f..0ff070e 100644
--- a/include/net/nfc/nci_core.h
+++ b/include/net/nfc/nci_core.h
@@ -21,8 +21,7 @@
  *  GNU General Public License for more details.
  *
  *  You should have received a copy of the GNU General Public License
- *  along with this program; if not, write to the Free Software
- *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-13=
07  USA
+ *  along with this program; if not, see <http://www.gnu.org/licenses/=
>.
  *
  */
=20
diff --git a/include/net/nfc/nfc.h b/include/net/nfc/nfc.h
index 82fc4e4..e80894b 100644
--- a/include/net/nfc/nfc.h
+++ b/include/net/nfc/nfc.h
@@ -16,9 +16,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the
- * Free Software Foundation, Inc.,
- * 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>=
=2E
  */
=20
 #ifndef __NET_NFC_H
diff --git a/include/net/sctp/auth.h b/include/net/sctp/auth.h
index aa80bef..f2d58aa 100644
--- a/include/net/sctp/auth.h
+++ b/include/net/sctp/auth.h
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
diff --git a/include/net/sctp/checksum.h b/include/net/sctp/checksum.h
index 6bd44fe..4a5b9a3 100644
--- a/include/net/sctp/checksum.h
+++ b/include/net/sctp/checksum.h
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
diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index 832f219..4b7cd69 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
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
diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.=
h
index 2f0a565..307728f 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
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
diff --git a/include/net/tc_act/tc_skbedit.h b/include/net/tc_act/tc_sk=
bedit.h
index e103fe0..dd5d86f 100644
--- a/include/net/tc_act/tc_skbedit.h
+++ b/include/net/tc_act/tc_skbedit.h
@@ -11,8 +11,7 @@
  * more details.
  *
  * You should have received a copy of the GNU General Public License a=
long with
- * this program; if not, write to the Free Software Foundation, Inc., =
59 Temple
- * Place - Suite 330, Boston, MA 02111-1307 USA.
+ * this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * Author: Alexander Duyck <alexander.h.duyck@intel.com>
  */
--=20
1.8.3.1
