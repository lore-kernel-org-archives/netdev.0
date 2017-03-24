From: Daniele Palmas <dnlplm@gmail.com>
Subject: [PATCH 2/2] Documentation: ABI: testing: sysfs-class-net-qmi: add new qmap mux files description
Date: Fri, 24 Mar 2017 14:22:46 +0100
Message-ID: <1490361766-24114-3-git-send-email-dnlplm@gmail.com>
References: <1490361766-24114-1-git-send-email-dnlplm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        Daniele Palmas <dnlplm@gmail.com>
To: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35594 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756022AbdCXNYO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 09:24:14 -0400
In-Reply-To: <1490361766-24114-1-git-send-email-dnlplm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the documentation related to the new files added for
qmap mux support.

Signed-off-by: Daniele Palmas <dnlplm@gmail.com>
---
 Documentation/ABI/testing/sysfs-class-net-qmi | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/Documentation/ABI/testing/sysfs-class-net-qmi b/Documentation/ABI/testing/sysfs-class-net-qmi
index fa5a00b..5191dc3 100644
--- a/Documentation/ABI/testing/sysfs-class-net-qmi
+++ b/Documentation/ABI/testing/sysfs-class-net-qmi
@@ -21,3 +21,30 @@ Description:
 		is responsible for coordination of driver and firmware
 		link framing mode, changing this setting to 'Y' if the
 		firmware is configured for 'raw-ip' mode.
+
+What:		/sys/class/net/<iface>/qmi/add_mux
+Date:		March 2017
+KernelVersion:	4.11
+Contact:	Bjørn Mork <bjorn@mork.no>
+Description:
+		Unsigned integer.
+
+		Write a number ranging from 1 to 127 to add a qmap mux
+		based network device, supported by recent Qualcomm based
+		modems.
+
+		The network device will be called qmimux.
+
+		Userspace is in charge of managing the qmux network device
+		activation and data stream setup  on them modem side by
+		using the proper QMI protocol requests.
+
+What:		/sys/class/net/<iface>/qmi/del_mux
+Date:		March 2017
+KernelVersion:	4.11
+Contact:	Bjørn Mork <bjorn@mork.no>
+Description:
+		Unsigned integer.
+
+		Write a number ranging from 1 to 127 to delete a previously
+		created qmap mux based network device.
-- 
2.8.1
