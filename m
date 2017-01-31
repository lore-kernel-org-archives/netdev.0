From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 04/17] net: stmmac: remove freesoftware address
Date: Tue, 31 Jan 2017 10:11:39 +0100
Message-ID: <20170131091152.13842-5-clabbe.montjoie@gmail.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:35547 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751218AbdAaJZO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 04:25:14 -0500
In-Reply-To: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fix the checkpatch warning about free software address.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c      | 4 ----
 drivers/net/ethernet/stmicro/stmmac/common.h          | 4 ----
 drivers/net/ethernet/stmicro/stmmac/descs.h           | 4 ----
 drivers/net/ethernet/stmicro/stmmac/descs_com.h       | 4 ----
 drivers/net/ethernet/stmicro/stmmac/dwmac100.h        | 4 ----
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h       | 4 ----
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c  | 4 ----
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c   | 4 ----
 drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c   | 4 ----
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c    | 4 ----
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h       | 4 ----
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c       | 4 ----
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c        | 4 ----
 drivers/net/ethernet/stmicro/stmmac/mmc.h             | 4 ----
 drivers/net/ethernet/stmicro/stmmac/mmc_core.c        | 4 ----
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c       | 4 ----
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c       | 4 ----
 drivers/net/ethernet/stmicro/stmmac/stmmac.h          | 4 ----
 drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c  | 4 ----
 drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c | 4 ----
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     | 4 ----
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c     | 4 ----
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c      | 4 ----
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 4 ----
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c      | 4 ----
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h      | 4 ----
 26 files changed, 104 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index 026e8e9..01a8c02 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -16,10 +16,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 0f90f91..9da4877 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -12,10 +12,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/descs.h b/drivers/net/ethernet/stmicro/stmmac/descs.h
index faeeef7..0c2432b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/descs.h
+++ b/drivers/net/ethernet/stmicro/stmmac/descs.h
@@ -11,10 +11,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/descs_com.h b/drivers/net/ethernet/stmicro/stmmac/descs_com.h
index 1d181e2..ca9d7e4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/descs_com.h
+++ b/drivers/net/ethernet/stmicro/stmmac/descs_com.h
@@ -17,10 +17,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100.h b/drivers/net/ethernet/stmicro/stmmac/dwmac100.h
index 1657acf..e149848 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100.h
@@ -12,10 +12,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
index 52b9407..c02d366 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
@@ -10,10 +10,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index 5484fd7..bfd8639 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -16,10 +16,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index 612d3aa..fbaec0f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -16,10 +16,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
index 9dd2987..8ab5189 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
@@ -18,10 +18,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
index e5664da..d40e91e8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
@@ -18,10 +18,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
index 726d9d9..56e485f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
@@ -12,10 +12,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
index 3b1570d..e4cda39 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
@@ -10,10 +10,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
index f0d8632..8427643 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -12,10 +12,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/mmc.h b/drivers/net/ethernet/stmicro/stmmac/mmc.h
index 38a1a56..c037326 100644
--- a/drivers/net/ethernet/stmicro/stmmac/mmc.h
+++ b/drivers/net/ethernet/stmicro/stmmac/mmc.h
@@ -12,10 +12,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c b/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
index ce9aa79..e9b04c2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
@@ -12,10 +12,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index fd78406..5a0d4b0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -12,10 +12,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
index 9983ce9..452f256 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -16,10 +16,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index eab04ae..c8273ef 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -10,10 +10,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 699ee1d..69db8cb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -12,10 +12,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
index 10d6059..721b616 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
@@ -12,10 +12,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index ee71c07..98f544e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -13,10 +13,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index a1a469e..738d5c7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -13,10 +13,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 3da4737..5c9e4622 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -12,10 +12,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 36942f5..eff6282 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -12,10 +12,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
index 3eb281d..d71bd80 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
@@ -12,10 +12,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
index c06938c..48fb72f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
@@ -12,10 +12,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
-- 
2.10.2
