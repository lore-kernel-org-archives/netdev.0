From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH 04/26] et131x: kill unused RCV_REF macros
Date: Tue, 25 Aug 2009 15:57:59 +0100
Message-ID: <20090825145756.16176.77191.stgit@localhost.localdomain>
References: <20090825145619.16176.68780.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: greg@kroah.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:42576 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755089AbZHYPDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 11:03:21 -0400
In-Reply-To: <20090825145619.16176.68780.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/staging/et131x/et131x_adapter.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)


diff --git a/drivers/staging/et131x/et131x_adapter.h b/drivers/staging/et131x/et131x_adapter.h
index 2b55319..82686ea 100644
--- a/drivers/staging/et131x/et131x_adapter.h
+++ b/drivers/staging/et131x/et131x_adapter.h
@@ -108,8 +108,6 @@
 #define MP_TEST_FLAGS(_M, _F)       (((_M)->Flags & (_F)) == (_F))
 #define MP_IS_FLAG_CLEAR(_M, _F)    (((_M)->Flags & (_F)) == 0)
 
-#define MP_INC_RCV_REF(_A)          atomic_inc(&(_A)->RcvRefCount)
-#define MP_DEC_RCV_REF(_A)          atomic_dec(&(_A)->RcvRefCount)
 #define MP_GET_RCV_REF(_A)          atomic_read(&(_A)->RcvRefCount)
 
 /* Macros specific to the private adapter structure */

