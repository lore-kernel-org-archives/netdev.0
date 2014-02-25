From: Joe Perches <joe@perches.com>
Subject: [PATCH] MAINTAINERS: Intel nic drivers
Date: Tue, 25 Feb 2014 13:35:53 -0800
Message-ID: <1393364153.8716.63.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new F: line for the intel subdirectories.

This allows get_maintainers to avoid using git log
and cc'ing people that have submitted clean-up style
patches for all first level directories under
drivers/net/ethernet/intel/

This does not make e100.c maintained.

Signed-off-by: Joe Perches <joe@perches.com>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 90baeb1..9778d12 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4574,6 +4574,7 @@ F:	Documentation/networking/ixgbevf.txt
 F:	Documentation/networking/i40e.txt
 F:	Documentation/networking/i40evf.txt
 F:	drivers/net/ethernet/intel/
+F:	drivers/net/ethernet/intel/*/
 
 INTEL-MID GPIO DRIVER
 M:	David Cohen <david.a.cohen@linux.intel.com>
