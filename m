From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH 1/1] ixgbe: replace defined with IS_ENABLED
Date: Mon, 19 Sep 2016 17:00:02 +0000
Message-ID: <87618083B2453E4A8714035B62D67992506E6E4B@FMSMSX105.amr.corp.intel.com>
References: <1473866814-21374-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "zyjzyj2000@gmail.com" <zyjzyj2000@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "e1000-devel@lists.sourceforge.net"
        <e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:31168 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750922AbcISRAE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 13:00:04 -0400
In-Reply-To: <1473866814-21374-1-git-send-email-zyjzyj2000@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of zyjzyj2000@gmail.com
>Sent: Wednesday, September 14, 2016 8:27 AM
>To: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org; Kirsher,
>Jeffrey T <jeffrey.t.kirsher@intel.com>; zyjzyj2000@gmail.com; e1000-
>devel@lists.sourceforge.net
>Subject: [PATCH 1/1] ixgbe: replace defined with IS_ENABLED
>
>From: Zhu Yanjun <zyjzyj2000@gmail.com>
>
>Replace defined macro with IS_ENABLED in ixgbe.h file
>
>Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
>---
> drivers/net/ethernet/intel/ixgbe/ixgbe.h | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>index 9475ff9..f8bc1d0 100644
>--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>@@ -45,7 +45,7 @@
> #include "ixgbe_type.h"
> #include "ixgbe_common.h"
> #include "ixgbe_dcb.h"
>-#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
>+#if IS_ENABLED(CONFIG_FCOE)
> #define IXGBE_FCOE
> #include "ixgbe_fcoe.h"
> #endif /* CONFIG_FCOE or CONFIG_FCOE_MODULE */
>--
>2.7.4

Already taken care of by the following patch:
http://patchwork.ozlabs.org/patch/668894/

Thanks,
Emil
 
