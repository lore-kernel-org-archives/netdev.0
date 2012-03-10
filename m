From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 1/1] MAINTAINERS: add an entry for the PHC code
Date: Sat, 10 Mar 2012 12:55:53 +0100
Message-ID: <24d5bd16fdf73810d57fe1756401277f92628e71.1331380050.git.richardcochran@gmail.com>
References: <cover.1331380050.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:54701 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752620Ab2CJL4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2012 06:56:04 -0500
Received: by wejx9 with SMTP id x9so1810295wej.19
        for <netdev@vger.kernel.org>; Sat, 10 Mar 2012 03:56:03 -0800 (PST)
In-Reply-To: <cover.1331380050.git.richardcochran@gmail.com>
In-Reply-To: <cover.1331380050.git.richardcochran@gmail.com>
References: <cover.1331380050.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some months ago, tglx asked me off list if I would maintain the PTP
Hardware Clock code. Since then, the code has been fully merged, and I
am actively looking after it. This patch makes it official.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
Acked-by: John Stultz <john.stultz@linaro.org>
---
 MAINTAINERS |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 0d01192..209a3862 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5317,6 +5317,17 @@ L:	cbe-oss-dev@lists.ozlabs.org
 S:	Maintained
 F:	drivers/block/ps3vram.c
 
+PTP HARDWARE CLOCK SUPPORT
+M:	Richard Cochran <richardcochran@gmail.com>
+S:	Maintained
+W:	http://linuxptp.sourceforge.net/
+F:	Documentation/ABI/testing/sysfs-ptp
+F:	Documentation/ptp/*
+F:	drivers/net/gianfar_ptp.c
+F:	drivers/net/phy/dp83640*
+F:	drivers/ptp/*
+F:	include/linux/ptp_cl*
+
 PTRACE SUPPORT
 M:	Roland McGrath <roland@redhat.com>
 M:	Oleg Nesterov <oleg@redhat.com>
-- 
1.7.2.5
