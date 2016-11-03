From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V4 8/9] liquidio CN23XX: copyrights changes and alignment
Date: Thu, 3 Nov 2016 14:35:17 -0700
Message-ID: <1478208918-8330-9-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1478208918-8330-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0073.outbound.protection.outlook.com ([104.47.34.73]:60288
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1760047AbcKCVgW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 17:36:22 -0400
In-Reply-To: <1478208918-8330-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updated copyrights comments and also changed some other comments
alignments.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    | 53 ++++++++++------------
 .../ethernet/cavium/liquidio/cn23xx_pf_device.h    | 39 +++++++---------
 .../net/ethernet/cavium/liquidio/cn23xx_pf_regs.h  | 39 +++++++---------
 .../net/ethernet/cavium/liquidio/cn66xx_device.c   | 36 +++++++--------
 .../net/ethernet/cavium/liquidio/cn66xx_device.h   | 37 +++++++--------
 drivers/net/ethernet/cavium/liquidio/cn66xx_regs.h | 37 +++++++--------
 .../net/ethernet/cavium/liquidio/cn68xx_device.c   | 36 +++++++--------
 .../net/ethernet/cavium/liquidio/cn68xx_device.h   | 37 +++++++--------
 drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h | 37 +++++++--------
 drivers/net/ethernet/cavium/liquidio/lio_core.c    | 36 +++++++--------
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 42 ++++++++---------
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 36 +++++++--------
 .../net/ethernet/cavium/liquidio/liquidio_common.h | 37 +++++++--------
 .../net/ethernet/cavium/liquidio/liquidio_image.h  | 36 +++++++--------
 .../net/ethernet/cavium/liquidio/octeon_config.h   | 37 +++++++--------
 .../net/ethernet/cavium/liquidio/octeon_console.c  | 43 ++++++++----------
 .../net/ethernet/cavium/liquidio/octeon_device.c   | 36 +++++++--------
 .../net/ethernet/cavium/liquidio/octeon_device.h   | 45 ++++++++----------
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c | 36 +++++++--------
 drivers/net/ethernet/cavium/liquidio/octeon_droq.h | 17 +++----
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   | 21 ++++-----
 drivers/net/ethernet/cavium/liquidio/octeon_main.h | 19 +++-----
 .../net/ethernet/cavium/liquidio/octeon_mem_ops.c  |  5 +-
 .../net/ethernet/cavium/liquidio/octeon_mem_ops.h  |  5 +-
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  5 +-
 drivers/net/ethernet/cavium/liquidio/octeon_nic.c  |  5 +-
 drivers/net/ethernet/cavium/liquidio/octeon_nic.h  |  5 +-
 .../net/ethernet/cavium/liquidio/request_manager.c |  5 +-
 .../ethernet/cavium/liquidio/response_manager.c    |  5 +-
 .../ethernet/cavium/liquidio/response_manager.h    |  5 +-
 30 files changed, 352 insertions(+), 480 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
index cbf9667..2644a84 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
@@ -1,27 +1,21 @@
 /**********************************************************************
-* Author: Cavium, Inc.
-*
-* Contact: support@cavium.com
-*          Please include "LiquidIO" in the subject.
-*
-* Copyright (c) 2003-2015 Cavium, Inc.
-*
-* This file is free software; you can redistribute it and/or modify
-* it under the terms of the GNU General Public License, Version 2, as
-* published by the Free Software Foundation.
-*
-* This file is distributed in the hope that it will be useful, but
-* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
-* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
-* NONINFRINGEMENT.  See the GNU General Public License for more
-* details.
-*
-* This file may also be available under a different license from Cavium.
-* Contact Cavium, Inc. for more information
-**********************************************************************/
-
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 #include <linux/pci.h>
-#include <linux/netdevice.h>
 #include <linux/vmalloc.h>
 #include <linux/etherdevice.h>
 #include "liquidio_common.h"
@@ -421,10 +415,10 @@ static int cn23xx_pf_setup_global_input_regs(struct octeon_device *oct)
 		return -1;
 
 	/** Set the MAC_NUM and PVF_NUM in IQ_PKT_CONTROL reg
-	* for all queues.Only PF can set these bits.
-	* bits 29:30 indicate the MAC num.
-	* bits 32:47 indicate the PVF num.
-	*/
+	 * for all queues.Only PF can set these bits.
+	 * bits 29:30 indicate the MAC num.
+	 * bits 32:47 indicate the PVF num.
+	 */
 	for (q_no = 0; q_no < ern; q_no++) {
 		reg_val = oct->pcie_port << CN23XX_PKT_INPUT_CTL_MAC_NUM_POS;
 
@@ -547,8 +541,8 @@ static void cn23xx_pf_setup_global_output_regs(struct octeon_device *oct)
 	writeq(0x40, (u8 *)oct->mmio[0].hw_addr + CN23XX_SLI_OQ_WMARK);
 
 	/** Disabling setting OQs in reset when ring has no dorebells
-	  * enabling this will cause of head of line blocking
-	  */
+	 * enabling this will cause of head of line blocking
+	 */
 	/* Do it only for pass1.1. and pass1.2 */
 	if ((oct->rev_id == OCTEON_CN23XX_REV_1_0) ||
 	    (oct->rev_id == OCTEON_CN23XX_REV_1_1))
@@ -1385,8 +1379,7 @@ void cn23xx_dump_iq_regs(struct octeon_device *oct)
 		dev_dbg(&oct->pci_dev->dev, "SLI_PKT[%d]_INPUT_CTL [0x%x]: 0x%016llx\n",
 			q_no, CN23XX_SLI_IQ_PKT_CONTROL64(q_no),
 			CVM_CAST64(octeon_read_csr64
-				(oct,
-					CN23XX_SLI_IQ_PKT_CONTROL64(q_no))));
+				(oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no))));
 	}
 
 	pci_read_config_dword(oct->pci_dev, CN23XX_CONFIG_PCIE_DEVCTL, &regval);
diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
index cee346a..2fedd91 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
@@ -1,28 +1,23 @@
 /**********************************************************************
-* Author: Cavium, Inc.
-*
-* Contact: support@cavium.com
-*          Please include "LiquidIO" in the subject.
-*
-* Copyright (c) 2003-2015 Cavium, Inc.
-*
-* This file is free software; you can redistribute it and/or modify
-* it under the terms of the GNU General Public License, Version 2, as
-* published by the Free Software Foundation.
-*
-* This file is distributed in the hope that it will be useful, but
-* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
-* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
-* NONINFRINGEMENT.  See the GNU General Public License for more
-* details.
-*
-* This file may also be available under a different license from Cavium.
-* Contact Cavium, Inc. for more information
-**********************************************************************/
-
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 /*! \file  cn23xx_device.h
  * \brief Host Driver: Routines that perform CN23XX specific operations.
-*/
+ */
 
 #ifndef __CN23XX_PF_DEVICE_H__
 #define __CN23XX_PF_DEVICE_H__
diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_regs.h b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_regs.h
index 03d79d9..680a405 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_regs.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_regs.h
@@ -1,29 +1,24 @@
 /**********************************************************************
-* Author: Cavium, Inc.
-*
-* Contact: support@cavium.com
-*          Please include "LiquidIO" in the subject.
-*
-* Copyright (c) 2003-2015 Cavium, Inc.
-*
-* This file is free software; you can redistribute it and/or modify
-* it under the terms of the GNU General Public License, Version 2, as
-* published by the Free Software Foundation.
-*
-* This file is distributed in the hope that it will be useful, but
-* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
-* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
-* NONINFRINGEMENT.  See the GNU General Public License for more
-* details.
-*
-* This file may also be available under a different license from Cavium.
-* Contact Cavium, Inc. for more information
-**********************************************************************/
-
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 /*! \file cn23xx_regs.h
  * \brief Host Driver: Register Address and Register Mask values for
  * Octeon CN23XX devices.
-*/
+ */
 
 #ifndef __CN23XX_PF_REGS_H__
 #define __CN23XX_PF_REGS_H__
diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
index 1ebc225..bdec051 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
@@ -1,24 +1,20 @@
 /**********************************************************************
-* Author: Cavium, Inc.
-*
-* Contact: support@cavium.com
-*          Please include "LiquidIO" in the subject.
-*
-* Copyright (c) 2003-2015 Cavium, Inc.
-*
-* This file is free software; you can redistribute it and/or modify
-* it under the terms of the GNU General Public License, Version 2, as
-* published by the Free Software Foundation.
-*
-* This file is distributed in the hope that it will be useful, but
-* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
-* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
-* NONINFRINGEMENT.  See the GNU General Public License for more
-* details.
-*
-* This file may also be available under a different license from Cavium.
-* Contact Cavium, Inc. for more information
-**********************************************************************/
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include "liquidio_common.h"
diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
index 32fbbb2..8ed5713 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
@@ -1,25 +1,20 @@
 /**********************************************************************
-* Author: Cavium, Inc.
-*
-* Contact: support@cavium.com
-*          Please include "LiquidIO" in the subject.
-*
-* Copyright (c) 2003-2015 Cavium, Inc.
-*
-* This file is free software; you can redistribute it and/or modify
-* it under the terms of the GNU General Public License, Version 2, as
-* published by the Free Software Foundation.
-*
-* This file is distributed in the hope that it will be useful, but
-* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
-* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
-* NONINFRINGEMENT.  See the GNU General Public License for more
-* details.
-*
-* This file may also be available under a different license from Cavium.
-* Contact Cavium, Inc. for more information
-**********************************************************************/
-
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 /*! \file  cn66xx_device.h
  *  \brief Host Driver: Routines that perform CN66XX specific operations.
  */
diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_regs.h b/drivers/net/ethernet/cavium/liquidio/cn66xx_regs.h
index 5e3aff2..23152c0 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_regs.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_regs.h
@@ -1,25 +1,20 @@
 /**********************************************************************
-* Author: Cavium, Inc.
-*
-* Contact: support@cavium.com
-*          Please include "LiquidIO" in the subject.
-*
-* Copyright (c) 2003-2015 Cavium, Inc.
-*
-* This file is free software; you can redistribute it and/or modify
-* it under the terms of the GNU General Public License, Version 2, as
-* published by the Free Software Foundation.
-*
-* This file is distributed in the hope that it will be useful, but
-* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
-* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
-* NONINFRINGEMENT.  See the GNU General Public License for more
-* details.
-*
-* This file may also be available under a different license from Cavium.
-* Contact Cavium, Inc. for more information
-**********************************************************************/
-
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 /*! \file cn66xx_regs.h
  *  \brief Host Driver: Register Address and Register Mask values for
  *  Octeon CN66XX devices.
diff --git a/drivers/net/ethernet/cavium/liquidio/cn68xx_device.c b/drivers/net/ethernet/cavium/liquidio/cn68xx_device.c
index dbf3566..1e40f1a 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn68xx_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn68xx_device.c
@@ -1,24 +1,20 @@
 /**********************************************************************
-* Author: Cavium, Inc.
-*
-* Contact: support@cavium.com
-*          Please include "LiquidIO" in the subject.
-*
-* Copyright (c) 2003-2015 Cavium, Inc.
-*
-* This file is free software; you can redistribute it and/or modify
-* it under the terms of the GNU General Public License, Version 2, as
-* published by the Free Software Foundation.
-*
-* This file is distributed in the hope that it will be useful, but
-* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
-* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
-* NONINFRINGEMENT.  See the GNU General Public License for more
-* details.
-*
-* This file may also be available under a different license from Cavium.
-* Contact Cavium, Inc. for more information
-**********************************************************************/
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include "liquidio_common.h"
diff --git a/drivers/net/ethernet/cavium/liquidio/cn68xx_device.h b/drivers/net/ethernet/cavium/liquidio/cn68xx_device.h
index ea7bdcc..66b8d6b 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn68xx_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn68xx_device.h
@@ -1,25 +1,20 @@
 /**********************************************************************
-* Author: Cavium, Inc.
-*
-* Contact: support@cavium.com
-*          Please include "LiquidIO" in the subject.
-*
-* Copyright (c) 2003-2015 Cavium, Inc.
-*
-* This file is free software; you can redistribute it and/or modify
-* it under the terms of the GNU General Public License, Version 2, as
-* published by the Free Software Foundation.
-*
-* This file is distributed in the hope that it will be useful, but
-* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
-* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
-* NONINFRINGEMENT.  See the GNU General Public License for more
-* details.
-*
-* This file may also be available under a different license from Cavium.
-* Contact Cavium, Inc. for more information
-**********************************************************************/
-
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 /*! \file  cn68xx_device.h
  *  \brief Host Driver: Routines that perform CN68XX specific operations.
  */
diff --git a/drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h b/drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h
index d45a0f4..0b742f0 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h
@@ -1,25 +1,20 @@
 /**********************************************************************
-* Author: Cavium, Inc.
-*
-* Contact: support@cavium.com
-*          Please include "LiquidIO" in the subject.
-*
-* Copyright (c) 2003-2015 Cavium, Inc.
-*
-* This file is free software; you can redistribute it and/or modify
-* it under the terms of the GNU General Public License, Version 2, as
-* published by the Free Software Foundation.
-*
-* This file is distributed in the hope that it will be useful, but
-* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
-* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
-* NONINFRINGEMENT.  See the GNU General Public License for more
-* details.
-*
-* This file may also be available under a different license from Cavium.
-* Contact Cavium, Inc. for more information
-**********************************************************************/
-
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 /*! \file cn68xx_regs.h
  *  \brief Host Driver: Register Address and Register Mask values for
  *  Octeon CN68XX devices. The register map for CN66XX is the same
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index e6026df..b28e740 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -1,24 +1,20 @@
 /**********************************************************************
-* Author: Cavium, Inc.
-*
-* Contact: support@cavium.com
-*          Please include "LiquidIO" in the subject.
-*
-* Copyright (c) 2003-2015 Cavium, Inc.
-*
-* This file is free software; you can redistribute it and/or modify
-* it under the terms of the GNU General Public License, Version 2, as
-* published by the Free Software Foundation.
-*
-* This file is distributed in the hope that it will be useful, but
-* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
-* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
-* NONINFRINGEMENT.  See the GNU General Public License for more
-* details.
-*
-* This file may also be available under a different license from Cavium.
-* Contact Cavium, Inc. for more information
-**********************************************************************/
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 #include <linux/pci.h>
 #include <linux/if_vlan.h>
 #include "liquidio_common.h"
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 1674522..c7c39a0 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -1,24 +1,20 @@
 /**********************************************************************
-* Author: Cavium, Inc.
-*
-* Contact: support@cavium.com
-*          Please include "LiquidIO" in the subject.
-*
-* Copyright (c) 2003-2015 Cavium, Inc.
-*
-* This file is free software; you can redistribute it and/or modify
-* it under the terms of the GNU General Public License, Version 2, as
-* published by the Free Software Foundation.
-*
-* This file is distributed in the hope that it will be useful, but
-* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
-* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
-* NONINFRINGEMENT.  See the GNU General Public License for more
-* details.
-*
-* This file may also be available under a different license from Cavium.
-* Contact Cavium, Inc. for more information
-**********************************************************************/
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 #include <linux/netdevice.h>
 #include <linux/net_tstamp.h>
 #include <linux/pci.h>
@@ -87,9 +83,9 @@ enum {
 	"tx_bytes",
 	"rx_errors",	/*jabber_err+l2_err+frame_err */
 	"tx_errors",	/*fw_err_pko+fw_err_link+fw_err_drop */
-	"rx_dropped",   /*st->fromwire.total_rcvd - st->fromwire.fw_total_rcvd
-			*+st->fromwire.dmac_drop + st->fromwire.fw_err_drop
-			*/
+	"rx_dropped",   /*st->fromwire.total_rcvd - st->fromwire.fw_total_rcvd +
+			 *st->fromwire.dmac_drop + st->fromwire.fw_err_drop
+			 */
 	"tx_dropped",
 
 	"tx_total_sent",
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index a9f19d2..bf0373a 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1,24 +1,20 @@
 /**********************************************************************
-* Author: Cavium, Inc.
-*
-* Contact: support@cavium.com
-*          Please include "LiquidIO" in the subject.
-*
-* Copyright (c) 2003-2015 Cavium, Inc.
-*
-* This file is free software; you can redistribute it and/or modify
-* it under the terms of the GNU General Public License, Version 2, as
-* published by the Free Software Foundation.
-*
-* This file is distributed in the hope that it will be useful, but
-* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
-* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
-* NONINFRINGEMENT.  See the GNU General Public License for more
-* details.
-*
-* This file may also be available under a different license from Cavium.
-* Contact Cavium, Inc. for more information
-**********************************************************************/
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 #include <linux/pci.h>
 #include <linux/firmware.h>
 #include <net/vxlan.h>
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 1d2eba7..82a4eed 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -1,25 +1,20 @@
 /**********************************************************************
-* Author: Cavium, Inc.
-*
-* Contact: support@cavium.com
-*          Please include "LiquidIO" in the subject.
-*
-* Copyright (c) 2003-2015 Cavium, Inc.
-*
-* This file is free software; you can redistribute it and/or modify
-* it under the terms of the GNU General Public License, Version 2, as
-* published by the Free Software Foundation.
-*
-* This file is distributed in the hope that it will be useful, but
-* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
-* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
-* NONINFRINGEMENT.  See the GNU General Public License for more
-* details.
-*
-* This file may also be available under a different license from Cavium.
-* Contact Cavium, Inc. for more information
-**********************************************************************/
-
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 /*!  \file  liquidio_common.h
  *   \brief Common: Structures and macros used in PCI-NIC package by core and
  *   host driver.
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_image.h b/drivers/net/ethernet/cavium/liquidio/liquidio_image.h
index 93819bd..78a3685 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_image.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_image.h
@@ -1,24 +1,20 @@
 /**********************************************************************
-* Author: Cavium, Inc.
-*
-* Contact: support@cavium.com
-*          Please include "LiquidIO" in the subject.
-*
-* Copyright (c) 2003-2015 Cavium, Inc.
-*
-* This file is free software; you can redistribute it and/or modify
-* it under the terms of the GNU General Public License, Version 2, as
-* published by the Free Software Foundation.
-*
-* This file is distributed in the hope that it will be useful, but
-* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
-* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
-* NONINFRINGEMENT.  See the GNU General Public License for more
-* details.
-*
-* This file may also be available under a different license from Cavium.
-* Contact Cavium, Inc. for more information
-**********************************************************************/
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 #ifndef _LIQUIDIO_IMAGE_H_
 #define _LIQUIDIO_IMAGE_H_
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_config.h b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
index 71daf82..1cb3514 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_config.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
@@ -1,25 +1,20 @@
 /**********************************************************************
-* Author: Cavium, Inc.
-*
-* Contact: support@cavium.com
-*          Please include "LiquidIO" in the subject.
-*
-* Copyright (c) 2003-2015 Cavium, Inc.
-*
-* This file is free software; you can redistribute it and/or modify
-* it under the terms of the GNU General Public License, Version 2, as
-* published by the Free Software Foundation.
-*
-* This file is distributed in the hope that it will be useful, but
-* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
-* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
-* NONINFRINGEMENT.  See the GNU General Public License for more
-* details.
-*
-* This file may also be available under a different license from Cavium.
-* Contact Cavium, Inc. for more information
-**********************************************************************/
-
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 /*! \file  octeon_config.h
  *  \brief Host Driver: Configuration data structures for the host driver.
  */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
index 01a50f3..c0089ed 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
@@ -1,25 +1,20 @@
 /**********************************************************************
-* Author: Cavium, Inc.
-*
-* Contact: support@cavium.com
-*          Please include "LiquidIO" in the subject.
-*
-* Copyright (c) 2003-2015 Cavium, Inc.
-*
-* This file is free software; you can redistribute it and/or modify
-* it under the terms of the GNU General Public License, Version 2, as
-* published by the Free Software Foundation.
-*
-* This file is distributed in the hope that it will be useful, but
-* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
-* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
-* NONINFRINGEMENT.  See the GNU General Public License for more
-* details.
-*
-* This file may also be available under a different license from Cavium.
-* Contact Cavium, Inc. for more information
-**********************************************************************/
-
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 /**
  * @file octeon_console.c
  */
@@ -76,9 +71,9 @@ static int octeon_console_read(struct octeon_device *oct, u32 console_num,
 #define OCTEON_CONSOLE_POLL_INTERVAL_MS  100    /* 10 times per second */
 
 /* First three members of cvmx_bootmem_desc are left in original
-** positions for backwards compatibility.
-** Assumes big endian target
-*/
+ * positions for backwards compatibility.
+ * Assumes big endian target
+ */
 struct cvmx_bootmem_desc {
 	/** spinlock to control access to list */
 	u32 lock;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 278c880..4a30d7c 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -1,24 +1,20 @@
 /**********************************************************************
-* Author: Cavium, Inc.
-*
-* Contact: support@cavium.com
-*          Please include "LiquidIO" in the subject.
-*
-* Copyright (c) 2003-2015 Cavium, Inc.
-*
-* This file is free software; you can redistribute it and/or modify
-* it under the terms of the GNU General Public License, Version 2, as
-* published by the Free Software Foundation.
-*
-* This file is distributed in the hope that it will be useful, but
-* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
-* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
-* NONINFRINGEMENT.  See the GNU General Public License for more
-* details.
-*
-* This file may also be available under a different license from Cavium.
-* Contact Cavium, Inc. for more information
-**********************************************************************/
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include <linux/vmalloc.h>
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 6c18baa..c59b77e 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -1,25 +1,20 @@
 /**********************************************************************
-* Author: Cavium, Inc.
-*
-* Contact: support@cavium.com
-*          Please include "LiquidIO" in the subject.
-*
-* Copyright (c) 2003-2015 Cavium, Inc.
-*
-* This file is free software; you can redistribute it and/or modify
-* it under the terms of the GNU General Public License, Version 2, as
-* published by the Free Software Foundation.
-*
-* This file is distributed in the hope that it will be useful, but
-* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
-* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
-* NONINFRINGEMENT.  See the GNU General Public License for more
-* details.
-*
-* This file may also be available under a different license from Cavium.
-* Contact Cavium, Inc. for more information
-**********************************************************************/
-
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 /*! \file octeon_device.h
  *  \brief Host Driver: This file defines the octeon device structure.
  */
@@ -93,9 +88,9 @@ enum octeon_pci_swap_mode {
 #define    OCT_DEV_STATES                 OCT_DEV_STATE_INVALID
 
 /** Octeon Device interrupts
-  *  These interrupt bits are set in int_status filed of
-  *  octeon_device structure
-  */
+ * These interrupt bits are set in int_status filed of
+ * octeon_device structure
+ */
 #define	   OCT_DEV_INTR_DMA0_FORCE	  0x01
 #define	   OCT_DEV_INTR_DMA1_FORCE	  0x02
 #define	   OCT_DEV_INTR_PKT_DATA	  0x04
@@ -548,7 +543,7 @@ struct oct_intrmod_cmd {
 void octeon_init_device_list(int conf_type);
 
 /** Free memory for Input and Output queue structures for a octeon device */
-void octeon_free_device_mem(struct octeon_device *);
+void octeon_free_device_mem(struct octeon_device *oct);
 
 /* Look up a free entry in the octeon_device table and allocate resources
  * for the octeon_device structure for an octeon device. Called at init
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index 8f6fc95..d7ba000 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -1,24 +1,20 @@
 /**********************************************************************
-* Author: Cavium, Inc.
-*
-* Contact: support@cavium.com
-*          Please include "LiquidIO" in the subject.
-*
-* Copyright (c) 2003-2015 Cavium, Inc.
-*
-* This file is free software; you can redistribute it and/or modify
-* it under the terms of the GNU General Public License, Version 2, as
-* published by the Free Software Foundation.
-*
-* This file is distributed in the hope that it will be useful, but
-* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
-* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
-* NONINFRINGEMENT.  See the GNU General Public License for more
-* details.
-*
-* This file may also be available under a different license from Cavium.
-* Contact Cavium, Inc. for more information
-**********************************************************************/
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include <linux/vmalloc.h>
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
index d591f5f..e620740 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
@@ -4,7 +4,7 @@
  * Contact: support@cavium.com
  *          Please include "LiquidIO" in the subject.
  *
- * Copyright (c) 2003-2015 Cavium, Inc.
+ * Copyright (c) 2003-2016 Cavium, Inc.
  *
  * This file is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License, Version 2, as
@@ -13,13 +13,8 @@
  * This file is distributed in the hope that it will be useful, but
  * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
  * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
- * NONINFRINGEMENT.  See the GNU General Public License for more
- * details.
- *
- * This file may also be available under a different license from Cavium.
- * Contact Cavium, Inc. for more information
- **********************************************************************/
-
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 /*!  \file  octeon_droq.h
  *   \brief Implementation of Octeon Output queues. "Output" is with
  *   respect to the Octeon device on the NIC. From this driver's point of
@@ -81,7 +76,7 @@ struct octeon_skb_page_info {
  *  the Octeon device. Since the descriptor ring keeps physical (bus)
  *  addresses, this field is required for the driver to keep track of
  *  the virtual address pointers.
-*/
+ */
 struct octeon_recv_buffer {
 	/** Packet buffer, including metadata. */
 	void *buffer;
@@ -358,7 +353,7 @@ struct octeon_droq {
  * @param  q_no       - droq no. ranges from 0 - 3.
  * @param app_ctx     - pointer to application context
  * @return Success: 0    Failure: 1
-*/
+ */
 int octeon_init_droq(struct octeon_device *oct_dev,
 		     u32 q_no,
 		     u32 num_descs,
@@ -371,7 +366,7 @@ int octeon_init_droq(struct octeon_device *oct_dev,
  *  @param oct_dev - pointer to the octeon device structure
  *  @param q_no    - droq no. ranges from 0 - 3.
  *  @return:    Success: 0    Failure: 1
-*/
+ */
 int octeon_delete_droq(struct octeon_device *oct_dev, u32 q_no);
 
 /** Register a change in droq operations. The ops field has a pointer to a
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
index b493e67..c67152a 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
@@ -4,7 +4,7 @@
  * Contact: support@cavium.com
  *          Please include "LiquidIO" in the subject.
  *
- * Copyright (c) 2003-2015 Cavium, Inc.
+ * Copyright (c) 2003-2016 Cavium, Inc.
  *
  * This file is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License, Version 2, as
@@ -13,13 +13,8 @@
  * This file is distributed in the hope that it will be useful, but
  * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
  * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
- * NONINFRINGEMENT.  See the GNU General Public License for more
- * details.
- *
- * This file may also be available under a different license from Cavium.
- * Contact Cavium, Inc. for more information
- **********************************************************************/
-
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 /*!  \file  octeon_iq.h
  *   \brief Host Driver: Implementation of Octeon input queues. "Input" is
  *   with respect to the Octeon device on the NIC. From this driver's
@@ -77,7 +72,7 @@ struct oct_iq_stats {
  *  The input queue is used to post raw (instruction) mode data or packet
  *  data to Octeon device from the host. Each input queue (upto 4) for
  *  a Octeon device has one such structure to represent it.
-*/
+ */
 struct octeon_instr_queue {
 	struct octeon_device *oct_dev;
 
@@ -117,8 +112,8 @@ struct octeon_instr_queue {
 	u32 octeon_read_index;
 
 	/** This index aids in finding the window in the queue where Octeon
-	  * has read the commands.
-	  */
+	 *  has read the commands.
+	 */
 	u32 flush_index;
 
 	/** This field keeps track of the instructions pending in this queue. */
@@ -149,8 +144,8 @@ struct octeon_instr_queue {
 	u64 last_db_time;
 
 	/** The doorbell timeout. If the doorbell was not rung for this time and
-	  * fill_cnt is non-zero, ring the doorbell again.
-	  */
+	 * fill_cnt is non-zero, ring the doorbell again.
+	 */
 	u32 db_timeout;
 
 	/** Statistics for this input queue. */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_main.h b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
index db86c63..8cd3891 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_main.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
@@ -4,7 +4,7 @@
  * Contact: support@cavium.com
  *          Please include "LiquidIO" in the subject.
  *
- * Copyright (c) 2003-2015 Cavium, Inc.
+ * Copyright (c) 2003-2016 Cavium, Inc.
  *
  * This file is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License, Version 2, as
@@ -13,13 +13,8 @@
  * This file is distributed in the hope that it will be useful, but
  * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
  * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
- * NONINFRINGEMENT.  See the GNU General Public License for more
- * details.
- *
- * This file may also be available under a different license from Cavium.
- * Contact Cavium, Inc. for more information
- **********************************************************************/
-
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
 /*! \file octeon_main.h
  *  \brief Host Driver: This file is included by all host driver source files
  *  to include common definitions.
@@ -78,10 +73,10 @@ static inline void octeon_swap_8B_data(u64 *data, u32 blocks)
 }
 
 /**
-  * \brief unmaps a PCI BAR
-  * @param oct Pointer to Octeon device
-  * @param baridx bar index
-  */
+ * \brief unmaps a PCI BAR
+ * @param oct Pointer to Octeon device
+ * @param baridx bar index
+ */
 static inline void octeon_unmap_pci_barx(struct octeon_device *oct, int baridx)
 {
 	dev_dbg(&oct->pci_dev->dev, "Freeing PCI mapped regions for Bar%d\n",
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
index 0dc081a..98d8066d 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
@@ -4,7 +4,7 @@
  * Contact: support@cavium.com
  *          Please include "LiquidIO" in the subject.
  *
- * Copyright (c) 2003-2015 Cavium, Inc.
+ * Copyright (c) 2003-2016 Cavium, Inc.
  *
  * This file is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License, Version 2, as
@@ -15,9 +15,6 @@
  * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
  * NONINFRINGEMENT.  See the GNU General Public License for more
  * details.
- *
- * This file may also be available under a different license from Cavium.
- * Contact Cavium, Inc. for more information
  **********************************************************************/
 #include <linux/netdevice.h>
 #include "liquidio_common.h"
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.h b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.h
index 11b1833..bae2fdd 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.h
@@ -4,7 +4,7 @@
  * Contact: support@cavium.com
  *          Please include "LiquidIO" in the subject.
  *
- * Copyright (c) 2003-2015 Cavium, Inc.
+ * Copyright (c) 2003-2016 Cavium, Inc.
  *
  * This file is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License, Version 2, as
@@ -15,9 +15,6 @@
  * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
  * NONINFRINGEMENT.  See the GNU General Public License for more
  * details.
- *
- * This file may also be available under a different license from Cavium.
- * Contact Cavium, Inc. for more information
  **********************************************************************/
 
 /*!  \file octeon_mem_ops.h
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index 54b9665..172b70e 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -4,7 +4,7 @@
  * Contact: support@cavium.com
  *          Please include "LiquidIO" in the subject.
  *
- * Copyright (c) 2003-2015 Cavium, Inc.
+ * Copyright (c) 2003-2016 Cavium, Inc.
  *
  * This file is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License, Version 2, as
@@ -15,9 +15,6 @@
  * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
  * NONINFRINGEMENT.  See the GNU General Public License for more
  * details.
- *
- * This file may also be available under a different license from Cavium.
- * Contact Cavium, Inc. for more information
  **********************************************************************/
 
 /*!  \file  octeon_network.h
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
index 40ac1fe..c3d6a82 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
@@ -4,7 +4,7 @@
  * Contact: support@cavium.com
  *          Please include "LiquidIO" in the subject.
  *
- * Copyright (c) 2003-2015 Cavium, Inc.
+ * Copyright (c) 2003-2016 Cavium, Inc.
  *
  * This file is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License, Version 2, as
@@ -15,9 +15,6 @@
  * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
  * NONINFRINGEMENT.  See the GNU General Public License for more
  * details.
- *
- * This file may also be available under a different license from Cavium.
- * Contact Cavium, Inc. for more information
  **********************************************************************/
 #include <linux/pci.h>
 #include <linux/netdevice.h>
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
index 4b8da67b..b059979 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
@@ -4,7 +4,7 @@
  * Contact: support@cavium.com
  *          Please include "LiquidIO" in the subject.
  *
- * Copyright (c) 2003-2015 Cavium, Inc.
+ * Copyright (c) 2003-2016 Cavium, Inc.
  *
  * This file is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License, Version 2, as
@@ -15,9 +15,6 @@
  * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
  * NONINFRINGEMENT.  See the GNU General Public License for more
  * details.
- *
- * This file may also be available under a different license from Cavium.
- * Contact Cavium, Inc. for more information
  **********************************************************************/
 
 /*!  \file octeon_nic.h
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index f6e1616..0cc1583 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -4,7 +4,7 @@
  * Contact: support@cavium.com
  *          Please include "LiquidIO" in the subject.
  *
- * Copyright (c) 2003-2015 Cavium, Inc.
+ * Copyright (c) 2003-2016 Cavium, Inc.
  *
  * This file is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License, Version 2, as
@@ -15,9 +15,6 @@
  * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
  * NONINFRINGEMENT.  See the GNU General Public License for more
  * details.
- *
- * This file may also be available under a different license from Cavium.
- * Contact Cavium, Inc. for more information
  **********************************************************************/
 #include <linux/pci.h>
 #include <linux/netdevice.h>
diff --git a/drivers/net/ethernet/cavium/liquidio/response_manager.c b/drivers/net/ethernet/cavium/liquidio/response_manager.c
index 9e496c1..fdaf742 100644
--- a/drivers/net/ethernet/cavium/liquidio/response_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/response_manager.c
@@ -4,7 +4,7 @@
  * Contact: support@cavium.com
  *          Please include "LiquidIO" in the subject.
  *
- * Copyright (c) 2003-2015 Cavium, Inc.
+ * Copyright (c) 2003-2016 Cavium, Inc.
  *
  * This file is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License, Version 2, as
@@ -15,9 +15,6 @@
  * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
  * NONINFRINGEMENT.  See the GNU General Public License for more
  * details.
- *
- * This file may also be available under a different license from Cavium.
- * Contact Cavium, Inc. for more information
  **********************************************************************/
 #include <linux/pci.h>
 #include <linux/netdevice.h>
diff --git a/drivers/net/ethernet/cavium/liquidio/response_manager.h b/drivers/net/ethernet/cavium/liquidio/response_manager.h
index d377faf..cbb2d84 100644
--- a/drivers/net/ethernet/cavium/liquidio/response_manager.h
+++ b/drivers/net/ethernet/cavium/liquidio/response_manager.h
@@ -4,7 +4,7 @@
  * Contact: support@cavium.com
  *          Please include "LiquidIO" in the subject.
  *
- * Copyright (c) 2003-2015 Cavium, Inc.
+ * Copyright (c) 2003-2016 Cavium, Inc.
  *
  * This file is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License, Version 2, as
@@ -15,9 +15,6 @@
  * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
  * NONINFRINGEMENT.  See the GNU General Public License for more
  * details.
- *
- * This file may also be available under a different license from Cavium.
- * Contact Cavium, Inc. for more information
  **********************************************************************/
 
 /*! \file response_manager.h
-- 
1.8.3.1
