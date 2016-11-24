From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] ibmvnic: drop duplicate header seq_file.h
Date: Thu, 24 Nov 2016 21:58:29 +0800
Message-ID: <9f2baee4e0a81ba8b5089a2b5a42f67678de4b06.1479989017.git.geliangtang@gmail.com>
References: <15299de49216a2360976ca37ff774cae9d27d88b.1479991297.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>, netdev@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        John Allen <jallen@linux.vnet.ibm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <15299de49216a2360976ca37ff774cae9d27d88b.1479991297.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drop duplicate header seq_file.h from ibmvnic.c.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 1e486d1..c125966 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -74,7 +74,6 @@
 #include <asm/iommu.h>
 #include <linux/uaccess.h>
 #include <asm/firmware.h>
-#include <linux/seq_file.h>
 #include <linux/workqueue.h>
 
 #include "ibmvnic.h"
-- 
2.9.3
