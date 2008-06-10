From: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Subject: [ofa-general] [PATCH v4 13/14] QLogic VNIC: Modifications to IB
	Kconfig and Makefile
Date: Tue, 10 Jun 2008 17:08:48 -0400
Message-ID: <20080610210848.11186.47989.stgit@dale>
References: <20080610205633.11186.45499.stgit@dale>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: amar.mudrankit@qlogic.com, poornima.kamath@qlogic.com
To: rdreier@cisco.com, general@lists.openfabrics.org, netdev@vger.kernel.org
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080610205633.11186.45499.stgit@dale>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

From: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>

This patch modifies the toplevel Infiniband Kconfig and Makefile
to include QLogic VNIC as new ULP.

Signed-off-by: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Signed-off-by: Poornima Kamath <poornima.kamath@qlogic.com>
Signed-off-by: Amar Mudrankit <amar.mudrankit@qlogic.com>
---

 drivers/infiniband/Kconfig  |    2 ++
 drivers/infiniband/Makefile |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index a5dc78a..0775df5 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -53,4 +53,6 @@ source "drivers/infiniband/ulp/srp/Kconfig"
 
 source "drivers/infiniband/ulp/iser/Kconfig"
 
+source "drivers/infiniband/ulp/qlgc_vnic/Kconfig"
+
 endif # INFINIBAND
diff --git a/drivers/infiniband/Makefile b/drivers/infiniband/Makefile
index ed35e44..845271e 100644
--- a/drivers/infiniband/Makefile
+++ b/drivers/infiniband/Makefile
@@ -9,3 +9,4 @@ obj-$(CONFIG_INFINIBAND_NES)		+= hw/nes/
 obj-$(CONFIG_INFINIBAND_IPOIB)		+= ulp/ipoib/
 obj-$(CONFIG_INFINIBAND_SRP)		+= ulp/srp/
 obj-$(CONFIG_INFINIBAND_ISER)		+= ulp/iser/
+obj-$(CONFIG_INFINIBAND_QLGC_VNIC)	+= ulp/qlgc_vnic/
