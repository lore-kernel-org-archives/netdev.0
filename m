From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 net-next 4/4] ptp: clarify the clock_name sysfs attribute
Date: Sat, 22 Sep 2012 09:42:56 +0200
Message-ID: <6bc914f0607428ab0d8f5d5fc42a5e87bedc95c5.1348299094.git.richardcochran@gmail.com>
References: <cover.1348299094.git.richardcochran@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:60234 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754400Ab2IVHnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 03:43:17 -0400
Received: by mail-we0-f174.google.com with SMTP id x8so2368173wey.19
        for <netdev@vger.kernel.org>; Sat, 22 Sep 2012 00:43:17 -0700 (PDT)
In-Reply-To: <cover.1348299094.git.richardcochran@gmail.com>
In-Reply-To: <cover.1348299094.git.richardcochran@gmail.com>
References: <cover.1348299094.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There has been some confusion among PHC driver authors about the
intended purpose of the clock_name attribute. This patch expands the
documation in order to clarify how the clock_name field should be
understood.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 Documentation/ABI/testing/sysfs-ptp |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-ptp b/Documentation/ABI/testing/sysfs-ptp
index d40d2b5..c906488 100644
--- a/Documentation/ABI/testing/sysfs-ptp
+++ b/Documentation/ABI/testing/sysfs-ptp
@@ -19,7 +19,10 @@ Date:		September 2010
 Contact:	Richard Cochran <richardcochran@gmail.com>
 Description:
 		This file contains the name of the PTP hardware clock
-		as a human readable string.
+		as a human readable string. The purpose of this
+		attribute is to provide the user with a "friendly
+		name" and to help distinguish PHY based devices from
+		MAC based ones.
 
 What:		/sys/class/ptp/ptpN/max_adjustment
 Date:		September 2010
-- 
1.7.2.5
