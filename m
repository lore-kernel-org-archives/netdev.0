From: =?UTF-8?q?Beno=C3=AEt=20Bourbi=C3=A9?= <benoit.bourbie@gmail.com>
Subject: [PATCH] net : fix typo
Date: Sun, 14 Apr 2013 14:33:12 -0500
Message-ID: <1365967993-3945-1-git-send-email-benoit.bourbie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: wimax@linuxwimax.org, netdev@vger.kernel.org,
	=?UTF-8?q?Beno=C3=AEt=20Bourbi=C3=A9?= <benoit.bourbie@gmail.com>
To: inaky.perez-gonzalez@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:40900 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753427Ab3DNTdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 15:33:52 -0400
Received: by mail-oa0-f44.google.com with SMTP id h1so3888726oag.3
        for <netdev@vger.kernel.org>; Sun, 14 Apr 2013 12:33:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ixed some grammar mistakes.


Signed-off-by: Beno=C3=AEt Bourbi=C3=A9 <benoit.bourbie@gmail.com>
---
 include/net/wimax.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/wimax.h b/include/net/wimax.h
index bbb74f9..4588407 100644
--- a/include/net/wimax.h
+++ b/include/net/wimax.h
@@ -103,7 +103,7 @@
  * over multicast groups. This allows to have multiple applications
  * monitoring them.
  *
- * Each command/signal gets assigned it's own attribute policy. This
+ * Each command/signal gets assigned its own attribute policy. This
  * way the validator will verify that all the attributes in there are
  * only the ones that should be for each command/signal. Thing of an
  * attribute mapping to a type+argumentname for each command/signal.
@@ -123,7 +123,7 @@
  *
  * If network interface X is a WiMAX device, there will be a Generic
  * Netlink family named "WiMAX X" and the device will present a
- * "wimax" directory in it's network sysfs directory
+ * "wimax" directory in its network sysfs directory
  * (/sys/class/net/DEVICE/wimax) [used by HAL].
  *
  * The inexistence of any of these means the device does not support
@@ -228,7 +228,7 @@
  * WiMAX stack.
  *
  * When initializing the hardware (_probe), after calling
- * wimax_dev_add(), query the device for it's RF Kill switches status
+ * wimax_dev_add(), query the device for its RF Kill switches status
  * and feed it back to the WiMAX stack using
  * wimax_report_rfkill_{hw,sw}(). If any switch is missing, always
  * report it as ON.
@@ -306,7 +306,7 @@ struct wimax_dev;
  *     DRIVERNAME-BUSNAME:BUSID (dev->bus->name, dev->bus_id).
  *
  * @id_table_node: [private] link to the list of wimax devices kept by
- *     id-table.c. Protected by it's own spinlock.
+ *     id-table.c. Protected by its own spinlock.
  *
  * @mutex: [private] Serializes all concurrent access and execution of
  *     operations.
--=20
1.8.2.470.g21ccebe.dirty
