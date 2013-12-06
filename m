From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/6] ethernet: Fix FSF address in file headers
Date: Fri,  6 Dec 2013 06:28:43 -0800
Message-ID: <1386340128-23397-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Santosh Raspatur <santosh@chelsio.com>,
	Dimitris Michailidis <dm@chelsio.com>,
	Michael Chan <mchan@broadcom.com>,
	Santiago Leon <santil@linux.vnet.ibm.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Olof Johansson <olof@lixom.net>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Nicolas Pitre <nico@fluxnic.net>,
	Steve Glendinning <steve.glendinning@shawell.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29046 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755171Ab3LFO2y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 09:28:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several files refer to an old address for the Free Software Foundation
in the file header comment.  Resolve by replacing the address with
the URL <http://www.gnu.org/licenses/> so that we do not have to keep
updating the header comments anytime the address changes.

CC: Santosh Raspatur <santosh@chelsio.com>
CC: Dimitris Michailidis <dm@chelsio.com>
CC: Michael Chan <mchan@broadcom.com>
CC: Santiago Leon <santil@linux.vnet.ibm.com>
CC: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
CC: Olof Johansson <olof@lixom.net>
CC: Manish Chopra <manish.chopra@qlogic.com>
CC: Sony Chacko <sony.chacko@qlogic.com>
CC: Rajesh Borundia <rajesh.borundia@qlogic.com>
CC: Nicolas Pitre <nico@fluxnic.net>
CC: Steve Glendinning <steve.glendinning@shawell.net>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/amd/amd8111e.c                     | 4 +---
 drivers/net/ethernet/amd/amd8111e.h                     | 4 +---
 drivers/net/ethernet/amd/au1000_eth.c                   | 3 +--
 drivers/net/ethernet/amd/au1000_eth.h                   | 3 +--
 drivers/net/ethernet/broadcom/sb1250-mac.c              | 3 +--
 drivers/net/ethernet/chelsio/cxgb/common.h              | 3 +--
 drivers/net/ethernet/chelsio/cxgb/cphy.h                | 3 +--
 drivers/net/ethernet/chelsio/cxgb/cpl5_cmd.h            | 3 +--
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c               | 3 +--
 drivers/net/ethernet/chelsio/cxgb/elmer0.h              | 3 +--
 drivers/net/ethernet/chelsio/cxgb/espi.c                | 3 +--
 drivers/net/ethernet/chelsio/cxgb/espi.h                | 3 +--
 drivers/net/ethernet/chelsio/cxgb/gmac.h                | 3 +--
 drivers/net/ethernet/chelsio/cxgb/mv88x201x.c           | 3 +--
 drivers/net/ethernet/chelsio/cxgb/pm3393.c              | 3 +--
 drivers/net/ethernet/chelsio/cxgb/regs.h                | 3 +--
 drivers/net/ethernet/chelsio/cxgb/sge.c                 | 3 +--
 drivers/net/ethernet/chelsio/cxgb/sge.h                 | 3 +--
 drivers/net/ethernet/chelsio/cxgb/subr.c                | 3 +--
 drivers/net/ethernet/chelsio/cxgb/suni1x10gexp_regs.h   | 3 +--
 drivers/net/ethernet/ibm/ibmveth.c                      | 3 +--
 drivers/net/ethernet/ibm/ibmveth.h                      | 3 +--
 drivers/net/ethernet/lantiq_etop.c                      | 3 +--
 drivers/net/ethernet/marvell/mv643xx_eth.c              | 3 +--
 drivers/net/ethernet/marvell/pxa168_eth.c               | 3 +--
 drivers/net/ethernet/natsemi/ns83820.c                  | 3 +--
 drivers/net/ethernet/netx-eth.c                         | 3 +--
 drivers/net/ethernet/nvidia/forcedeth.c                 | 3 +--
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h         | 3 +--
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c     | 3 +--
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.h     | 3 +--
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c | 3 +--
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c    | 3 +--
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c   | 3 +--
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c     | 3 +--
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h     | 3 +--
 drivers/net/ethernet/pasemi/pasemi_mac.c                | 3 +--
 drivers/net/ethernet/pasemi/pasemi_mac.h                | 3 +--
 drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c        | 3 +--
 drivers/net/ethernet/qlogic/netxen/Makefile             | 4 +---
 drivers/net/ethernet/qlogic/netxen/netxen_nic.h         | 4 +---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c     | 4 +---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c | 4 +---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h     | 4 +---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c      | 4 +---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.h      | 4 +---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c    | 4 +---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c    | 4 +---
 drivers/net/ethernet/smsc/smc911x.c                     | 3 +--
 drivers/net/ethernet/smsc/smc911x.h                     | 3 +--
 drivers/net/ethernet/smsc/smc91x.c                      | 3 +--
 drivers/net/ethernet/smsc/smc91x.h                      | 3 +--
 drivers/net/ethernet/smsc/smsc911x.c                    | 3 +--
 drivers/net/ethernet/smsc/smsc911x.h                    | 3 +--
 drivers/net/ethernet/smsc/smsc9420.c                    | 3 +--
 drivers/net/ethernet/smsc/smsc9420.h                    | 3 +--
 drivers/net/ethernet/sun/cassini.c                      | 4 +---
 drivers/net/ethernet/sun/cassini.h                      | 4 +---
 drivers/net/ethernet/tundra/tsi108_eth.h                | 4 +---
 drivers/net/ethernet/xircom/xirc2ps_cs.c                | 3 +--
 60 files changed, 60 insertions(+), 134 deletions(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index d042511..d6beba0 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -24,9 +24,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
- * USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
 
 Module Name:
 
diff --git a/drivers/net/ethernet/amd/amd8111e.h b/drivers/net/ethernet/amd/amd8111e.h
index 8baa352..b1fae36 100644
--- a/drivers/net/ethernet/amd/amd8111e.h
+++ b/drivers/net/ethernet/amd/amd8111e.h
@@ -13,9 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
- * USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
 
 Module Name:
 
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index 427c148..2eee576 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -27,8 +27,7 @@
  *  for more details.
  *
  *  You should have received a copy of the GNU General Public License along
- *  with this program; if not, write to the Free Software Foundation, Inc.,
- *  59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
+ *  with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * ########################################################################
  *
diff --git a/drivers/net/ethernet/amd/au1000_eth.h b/drivers/net/ethernet/amd/au1000_eth.h
index 4b7f7ad..ca53024 100644
--- a/drivers/net/ethernet/amd/au1000_eth.h
+++ b/drivers/net/ethernet/amd/au1000_eth.h
@@ -18,8 +18,7 @@
  *  for more details.
  *
  *  You should have received a copy of the GNU General Public License along
- *  with this program; if not, write to the Free Software Foundation, Inc.,
- *  59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
+ *  with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * ########################################################################
  *
diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
index c277771..31a076d 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  *
  * This driver is designed for the Broadcom SiByte SOC built-in
diff --git a/drivers/net/ethernet/chelsio/cxgb/common.h b/drivers/net/ethernet/chelsio/cxgb/common.h
index 8abb46b..5dd20f7 100644
--- a/drivers/net/ethernet/chelsio/cxgb/common.h
+++ b/drivers/net/ethernet/chelsio/cxgb/common.h
@@ -11,8 +11,7 @@
  * published by the Free Software Foundation.                                *
  *                                                                           *
  * You should have received a copy of the GNU General Public License along   *
- * with this program; if not, write to the Free Software Foundation, Inc.,   *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ * with this program; if not, see <http://www.gnu.org/licenses/>.            *
  *                                                                           *
  * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
  * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
diff --git a/drivers/net/ethernet/chelsio/cxgb/cphy.h b/drivers/net/ethernet/chelsio/cxgb/cphy.h
index 1f095a9..a4d2a4c 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cphy.h
+++ b/drivers/net/ethernet/chelsio/cxgb/cphy.h
@@ -11,8 +11,7 @@
  * published by the Free Software Foundation.                                *
  *                                                                           *
  * You should have received a copy of the GNU General Public License along   *
- * with this program; if not, write to the Free Software Foundation, Inc.,   *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ * with this program; if not, see <http://www.gnu.org/licenses/>.            *
  *                                                                           *
  * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
  * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
diff --git a/drivers/net/ethernet/chelsio/cxgb/cpl5_cmd.h b/drivers/net/ethernet/chelsio/cxgb/cpl5_cmd.h
index e36d45b..5249686 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cpl5_cmd.h
+++ b/drivers/net/ethernet/chelsio/cxgb/cpl5_cmd.h
@@ -11,8 +11,7 @@
  * published by the Free Software Foundation.                                *
  *                                                                           *
  * You should have received a copy of the GNU General Public License along   *
- * with this program; if not, write to the Free Software Foundation, Inc.,   *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ * with this program; if not, see <http://www.gnu.org/licenses/>.            *
  *                                                                           *
  * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
  * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
diff --git a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
index 1d02105..e598713 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
+++ b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
@@ -11,8 +11,7 @@
  * published by the Free Software Foundation.                                *
  *                                                                           *
  * You should have received a copy of the GNU General Public License along   *
- * with this program; if not, write to the Free Software Foundation, Inc.,   *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ * with this program; if not, see <http://www.gnu.org/licenses/>.            *
  *                                                                           *
  * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
  * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
diff --git a/drivers/net/ethernet/chelsio/cxgb/elmer0.h b/drivers/net/ethernet/chelsio/cxgb/elmer0.h
index eef655c..81526ad 100644
--- a/drivers/net/ethernet/chelsio/cxgb/elmer0.h
+++ b/drivers/net/ethernet/chelsio/cxgb/elmer0.h
@@ -11,8 +11,7 @@
  * published by the Free Software Foundation.                                *
  *                                                                           *
  * You should have received a copy of the GNU General Public License along   *
- * with this program; if not, write to the Free Software Foundation, Inc.,   *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ * with this program; if not, see <http://www.gnu.org/licenses/>.            *
  *                                                                           *
  * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
  * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
diff --git a/drivers/net/ethernet/chelsio/cxgb/espi.c b/drivers/net/ethernet/chelsio/cxgb/espi.c
index 639ff19..3e182ee 100644
--- a/drivers/net/ethernet/chelsio/cxgb/espi.c
+++ b/drivers/net/ethernet/chelsio/cxgb/espi.c
@@ -12,8 +12,7 @@
  * published by the Free Software Foundation.                                *
  *                                                                           *
  * You should have received a copy of the GNU General Public License along   *
- * with this program; if not, write to the Free Software Foundation, Inc.,   *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ * with this program; if not, see <http://www.gnu.org/licenses/>.            *
  *                                                                           *
  * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
  * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
diff --git a/drivers/net/ethernet/chelsio/cxgb/espi.h b/drivers/net/ethernet/chelsio/cxgb/espi.h
index 5694aad..162de52 100644
--- a/drivers/net/ethernet/chelsio/cxgb/espi.h
+++ b/drivers/net/ethernet/chelsio/cxgb/espi.h
@@ -11,8 +11,7 @@
  * published by the Free Software Foundation.                                *
  *                                                                           *
  * You should have received a copy of the GNU General Public License along   *
- * with this program; if not, write to the Free Software Foundation, Inc.,   *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ * with this program; if not, see <http://www.gnu.org/licenses/>.            *
  *                                                                           *
  * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
  * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
diff --git a/drivers/net/ethernet/chelsio/cxgb/gmac.h b/drivers/net/ethernet/chelsio/cxgb/gmac.h
index d423374..dfa7749 100644
--- a/drivers/net/ethernet/chelsio/cxgb/gmac.h
+++ b/drivers/net/ethernet/chelsio/cxgb/gmac.h
@@ -12,8 +12,7 @@
  * published by the Free Software Foundation.                                *
  *                                                                           *
  * You should have received a copy of the GNU General Public License along   *
- * with this program; if not, write to the Free Software Foundation, Inc.,   *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ * with this program; if not, see <http://www.gnu.org/licenses/>.            *
  *                                                                           *
  * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
  * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
diff --git a/drivers/net/ethernet/chelsio/cxgb/mv88x201x.c b/drivers/net/ethernet/chelsio/cxgb/mv88x201x.c
index f7136b2..d0cf611 100644
--- a/drivers/net/ethernet/chelsio/cxgb/mv88x201x.c
+++ b/drivers/net/ethernet/chelsio/cxgb/mv88x201x.c
@@ -12,8 +12,7 @@
  * published by the Free Software Foundation.                                *
  *                                                                           *
  * You should have received a copy of the GNU General Public License along   *
- * with this program; if not, write to the Free Software Foundation, Inc.,   *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ * with this program; if not, see <http://www.gnu.org/licenses/>.            *
  *                                                                           *
  * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
  * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
diff --git a/drivers/net/ethernet/chelsio/cxgb/pm3393.c b/drivers/net/ethernet/chelsio/cxgb/pm3393.c
index eb33a31..ec5e050 100644
--- a/drivers/net/ethernet/chelsio/cxgb/pm3393.c
+++ b/drivers/net/ethernet/chelsio/cxgb/pm3393.c
@@ -12,8 +12,7 @@
  * published by the Free Software Foundation.                                *
  *                                                                           *
  * You should have received a copy of the GNU General Public License along   *
- * with this program; if not, write to the Free Software Foundation, Inc.,   *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ * with this program; if not, see <http://www.gnu.org/licenses/>.            *
  *                                                                           *
  * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
  * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
diff --git a/drivers/net/ethernet/chelsio/cxgb/regs.h b/drivers/net/ethernet/chelsio/cxgb/regs.h
index c80bf4d..964ce59 100644
--- a/drivers/net/ethernet/chelsio/cxgb/regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb/regs.h
@@ -11,8 +11,7 @@
  * published by the Free Software Foundation.                                *
  *                                                                           *
  * You should have received a copy of the GNU General Public License along   *
- * with this program; if not, write to the Free Software Foundation, Inc.,   *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ * with this program; if not, see <http://www.gnu.org/licenses/>.            *
  *                                                                           *
  * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
  * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethernet/chelsio/cxgb/sge.c
index 8061fb0..0341537 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -12,8 +12,7 @@
  * published by the Free Software Foundation.                                *
  *                                                                           *
  * You should have received a copy of the GNU General Public License along   *
- * with this program; if not, write to the Free Software Foundation, Inc.,   *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ * with this program; if not, see <http://www.gnu.org/licenses/>.            *
  *                                                                           *
  * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
  * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.h b/drivers/net/ethernet/chelsio/cxgb/sge.h
index b9bf16b..a1ba591 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.h
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.h
@@ -11,8 +11,7 @@
  * published by the Free Software Foundation.                                *
  *                                                                           *
  * You should have received a copy of the GNU General Public License along   *
- * with this program; if not, write to the Free Software Foundation, Inc.,   *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ * with this program; if not, see <http://www.gnu.org/licenses/>.            *
  *                                                                           *
  * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
  * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
diff --git a/drivers/net/ethernet/chelsio/cxgb/subr.c b/drivers/net/ethernet/chelsio/cxgb/subr.c
index e0a03a3..8167193 100644
--- a/drivers/net/ethernet/chelsio/cxgb/subr.c
+++ b/drivers/net/ethernet/chelsio/cxgb/subr.c
@@ -12,8 +12,7 @@
  * published by the Free Software Foundation.                                *
  *                                                                           *
  * You should have received a copy of the GNU General Public License along   *
- * with this program; if not, write to the Free Software Foundation, Inc.,   *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ * with this program; if not, see <http://www.gnu.org/licenses/>.            *
  *                                                                           *
  * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
  * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
diff --git a/drivers/net/ethernet/chelsio/cxgb/suni1x10gexp_regs.h b/drivers/net/ethernet/chelsio/cxgb/suni1x10gexp_regs.h
index d0f87d8..7f79cc7 100644
--- a/drivers/net/ethernet/chelsio/cxgb/suni1x10gexp_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb/suni1x10gexp_regs.h
@@ -12,8 +12,7 @@
  * published by the Free Software Foundation.                                *
  *                                                                           *
  * You should have received a copy of the GNU General Public License along   *
- * with this program; if not, write to the Free Software Foundation, Inc.,   *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ * with this program; if not, see <http://www.gnu.org/licenses/>.            *
  *                                                                           *
  * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
  * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 952d795..cde0fd9 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -12,8 +12,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * Copyright (C) IBM Corporation, 2003, 2010
  *
diff --git a/drivers/net/ethernet/ibm/ibmveth.h b/drivers/net/ethernet/ibm/ibmveth.h
index 84066ba..451ba79 100644
--- a/drivers/net/ethernet/ibm/ibmveth.h
+++ b/drivers/net/ethernet/ibm/ibmveth.h
@@ -12,8 +12,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * Copyright (C) IBM Corporation, 2003, 2010
  *
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 6a6c1f7..974a007 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -9,8 +9,7 @@
  *   GNU General Public License for more details.
  *
  *   You should have received a copy of the GNU General Public License
- *   along with this program; if not, write to the Free Software
- *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
+ *   along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  *   Copyright (C) 2011 John Crispin <blogic@openwrt.org>
  */
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 61088a6..fa90505 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -33,8 +33,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index fff6246..2ad3241 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -19,8 +19,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/init.h>
diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index d3b4700..5213e73 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -22,8 +22,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  *
  * ChangeLog
diff --git a/drivers/net/ethernet/netx-eth.c b/drivers/net/ethernet/netx-eth.c
index e6f0a43..31eb911 100644
--- a/drivers/net/ethernet/netx-eth.c
+++ b/drivers/net/ethernet/netx-eth.c
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/init.h>
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 1e8b951..1f1a472 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -26,8 +26,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
index 2a900307..2a55d6d 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
@@ -14,8 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef _PCH_GBE_H_
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c
index ff3ad70..5125036 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c
@@ -14,8 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 #include "pch_gbe.h"
 #include "pch_gbe_phy.h"
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.h
index 94aaac5..91ce07c 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.h
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.h
@@ -14,8 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 #ifndef _PCH_GBE_API_H_
 #define _PCH_GBE_API_H_
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
index f0ceb89..826f0cc 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
@@ -14,8 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 #include "pch_gbe.h"
 #include "pch_gbe_api.h"
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 27ffe0e..464e910 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -14,8 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "pch_gbe.h"
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c
index cf7c9b3..08d4be6 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c
@@ -14,8 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "pch_gbe.h"
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
index 8b7ff75..a5cad5e 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
@@ -14,8 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include "pch_gbe.h"
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h
index 0cbe692..95ad015 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h
@@ -14,8 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 #ifndef _PCH_GBE_PHY_H_
 #define _PCH_GBE_PHY_H_
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index dbaa49e..0734758 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #include <linux/init.h>
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.h b/drivers/net/ethernet/pasemi/pasemi_mac.h
index f2749d4..a580770 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.h
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.h
@@ -14,8 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 #ifndef PASEMI_MAC_H
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c b/drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c
index 4825959..25fae56 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 
diff --git a/drivers/net/ethernet/qlogic/netxen/Makefile b/drivers/net/ethernet/qlogic/netxen/Makefile
index 861a059..e14e60c 100644
--- a/drivers/net/ethernet/qlogic/netxen/Makefile
+++ b/drivers/net/ethernet/qlogic/netxen/Makefile
@@ -13,9 +13,7 @@
 # GNU General Public License for more details.
 #                                   
 # You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software
-# Foundation, Inc., 59 Temple Place - Suite 330, Boston,
-# MA  02111-1307, USA.
+# along with this program; if not, see <http://www.gnu.org/licenses/>.
 # 
 # The full GNU General Public License is included in this distribution
 # in the file called "COPYING".
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
index 9adcdbb..6e426ae 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
@@ -14,9 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
- * MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * The full GNU General Public License is included in this distribution
  * in the file called "COPYING".
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
index 1bcaf45..6f6be57 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
@@ -14,9 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
- * MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * The full GNU General Public License is included in this distribution
  * in the file called "COPYING".
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
index 4ca2c19..87e073c6 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
@@ -14,9 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
- * MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * The full GNU General Public License is included in this distribution
  * in the file called "COPYING".
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h
index 0c64c82..a310c2f 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h
@@ -14,9 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
- * MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * The full GNU General Public License is included in this distribution
  * in the file called "COPYING".
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
index 67efe75..b72b6be 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
@@ -14,9 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
- * MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * The full GNU General Public License is included in this distribution
  * in the file called "COPYING".
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.h
index e2c5b6f..7433c4d 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.h
@@ -14,9 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
- * MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * The full GNU General Public License is included in this distribution
  * in the file called "COPYING".
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index 7692dfd..3010abb 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -14,9 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
- * MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * The full GNU General Public License is included in this distribution
  * in the file called "COPYING".
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 3bec8cf..70849de 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -14,9 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
- * MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * The full GNU General Public License is included in this distribution
  * in the file called "COPYING".
diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index 0f096a8..5a4278d 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -17,8 +17,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * Arguments:
  *	 watchdog  = TX watchdog timeout
diff --git a/drivers/net/ethernet/smsc/smc911x.h b/drivers/net/ethernet/smsc/smc911x.h
index 9965da3..04b35f5 100644
--- a/drivers/net/ethernet/smsc/smc911x.h
+++ b/drivers/net/ethernet/smsc/smc911x.h
@@ -15,8 +15,7 @@
  . GNU General Public License for more details.
  .
  . You should have received a copy of the GNU General Public License
- . along with this program; if not, write to the Free Software
- . Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ . along with this program; if not, see <http://www.gnu.org/licenses/>.
  .
  . Information contained in this file was obtained from the LAN9118
  . manual from SMC.  To get a copy, if you really want one, you can find
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 0c9b5d9..b84c4dd 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -19,8 +19,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * Arguments:
  * 	io	= for the base address
diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
index 749654b..47dce91 100644
--- a/drivers/net/ethernet/smsc/smc91x.h
+++ b/drivers/net/ethernet/smsc/smc91x.h
@@ -18,8 +18,7 @@
  . GNU General Public License for more details.
  .
  . You should have received a copy of the GNU General Public License
- . along with this program; if not, write to the Free Software
- . Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ . along with this program; if not, see <http://www.gnu.org/licenses/>.
  .
  . Information contained in this file was obtained from the LAN91C111
  . manual from SMC.  To get a copy, if you really want one, you can find
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 8564f23..6382b7c 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -14,8 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  ***************************************************************************
  * Rewritten, heavily based on smsc911x simple driver by SMSC.
diff --git a/drivers/net/ethernet/smsc/smsc911x.h b/drivers/net/ethernet/smsc/smsc911x.h
index 9ad5e5d..2395395 100644
--- a/drivers/net/ethernet/smsc/smsc911x.h
+++ b/drivers/net/ethernet/smsc/smsc911x.h
@@ -14,8 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  ***************************************************************************/
 #ifndef __SMSC911X_H__
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index f433d97..9d6effe 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  ***************************************************************************
  */
diff --git a/drivers/net/ethernet/smsc/smsc9420.h b/drivers/net/ethernet/smsc/smsc9420.h
index e441402..c63c763 100644
--- a/drivers/net/ethernet/smsc/smsc9420.h
+++ b/drivers/net/ethernet/smsc/smsc9420.h
@@ -13,8 +13,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  ***************************************************************************
  */
diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index b4d50d7..df8d383 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -14,9 +14,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
- * 02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * This driver uses the sungem driver (c) David Miller
  * (davem@redhat.com) as its basis.
diff --git a/drivers/net/ethernet/sun/cassini.h b/drivers/net/ethernet/sun/cassini.h
index b361424..882ce16 100644
--- a/drivers/net/ethernet/sun/cassini.h
+++ b/drivers/net/ethernet/sun/cassini.h
@@ -15,9 +15,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
- * 02111-1307, USA.
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * vendor id: 0x108E (Sun Microsystems, Inc.)
  * device id: 0xabba (Cassini)
diff --git a/drivers/net/ethernet/tundra/tsi108_eth.h b/drivers/net/ethernet/tundra/tsi108_eth.h
index 5fee7d7..4a03c59 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.h
+++ b/drivers/net/ethernet/tundra/tsi108_eth.h
@@ -16,9 +16,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
- * MA 02111-1307 USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
 /*
diff --git a/drivers/net/ethernet/xircom/xirc2ps_cs.c b/drivers/net/ethernet/xircom/xirc2ps_cs.c
index bdd20b8..7c81ffb 100644
--- a/drivers/net/ethernet/xircom/xirc2ps_cs.c
+++ b/drivers/net/ethernet/xircom/xirc2ps_cs.c
@@ -27,8 +27,7 @@
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  *
  * ALTERNATIVELY, this driver may be distributed under the terms of
-- 
1.8.3.1
