From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] ptp: update adjfreq callback description
Date: Thu,  1 Nov 2012 15:30:16 -0700
Message-ID: <1351809016-29237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, stable@vger.kernel.org,
	richard.cochran@gmail.com, john.stultz@linaro.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:13621 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762451Ab2KAWax (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2012 18:30:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch updates the adjfreq callback description to include a note that the
delta in ppb is always relative to the base frequency, and not to the current
frequency of the hardware clock.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
CC: stable@vger.kernel.org [v3.5+]
CC: Richard Cochran <richard.cochran@gmail.com>
CC: John Stultz <john.stultz@linaro.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/ptp_clock_kernel.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
index f2dc6d8..38a9935 100644
--- a/include/linux/ptp_clock_kernel.h
+++ b/include/linux/ptp_clock_kernel.h
@@ -54,7 +54,8 @@ struct ptp_clock_request {
  * clock operations
  *
  * @adjfreq:  Adjusts the frequency of the hardware clock.
- *            parameter delta: Desired period change in parts per billion.
+ *            parameter delta: Desired frequency offset from nominal frequency
+ *            in parts per billion
  *
  * @adjtime:  Shifts the time of the hardware clock.
  *            parameter delta: Desired change in nanoseconds.
-- 
1.7.11.7
