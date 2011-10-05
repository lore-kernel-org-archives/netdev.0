From: Nathan Williams <nathan@traverse.com.au>
Subject: [PATCH 1/4] atm: solos-pci: Add AnnexA/M capability attributes
Date: Wed, 05 Oct 2011 15:43:30 +1100
Message-ID: <1317789810.2424.82.camel@dualcore.traverse>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net,
	David Woodhouse <dwmw2@infradead.org>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

BisACapability and BisMCapability allow users to
force either Annex A or Annex M.

Signed-off-by: Nathan Williams <nathan@traverse.com.au>
---
 drivers/atm/solos-attrlist.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/atm/solos-attrlist.c b/drivers/atm/solos-attrlist.c
index 9a676ee..8092533 100644
--- a/drivers/atm/solos-attrlist.c
+++ b/drivers/atm/solos-attrlist.c
@@ -71,6 +71,8 @@ SOLOS_ATTR_RW(BisAForceSNRMarginDn)
 SOLOS_ATTR_RW(BisMForceSNRMarginDn)
 SOLOS_ATTR_RW(BisAMaxMargin)
 SOLOS_ATTR_RW(BisMMaxMargin)
+SOLOS_ATTR_RW(BisACapability)
+SOLOS_ATTR_RW(BisMCapability)
 SOLOS_ATTR_RW(AnnexAForceSNRMarginDn)
 SOLOS_ATTR_RW(AnnexAMaxMargin)
 SOLOS_ATTR_RW(AnnexMMaxMargin)
-- 
1.7.2.5
