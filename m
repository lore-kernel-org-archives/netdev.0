From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita@gmail.com>
Subject: [PATCH 7/8] rfkill: Update userspace API documentation
Date: Tue, 19 Jan 2016 10:42:42 -0500
Message-ID: <1453218163-31998-8-git-send-email-jprvita@endlessm.com>
References: <1453218163-31998-1-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: marcel@holtmann.org, linux-wireless@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jprvita@endlessm.com,
	linux@endlessm.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f66.google.com ([209.85.192.66]:33539 "EHLO
	mail-qg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756357AbcASPoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 10:44:10 -0500
In-Reply-To: <1453218163-31998-1-git-send-email-jprvita@endlessm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a note to userspace on the effect of RFKILL_OP_CHANGE_ALL also
updating the default state for hotplugged devices.

Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@endlessm.com>
---
 include/uapi/linux/rfkill.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/rfkill.h b/include/uapi/linux/rfkill.h
index 058757f..c15fcfc 100644
--- a/include/uapi/linux/rfkill.h
+++ b/include/uapi/linux/rfkill.h
@@ -59,6 +59,7 @@ enum rfkill_type {
  * @RFKILL_OP_DEL: a device was removed
  * @RFKILL_OP_CHANGE: a device's state changed -- userspace changes on=
e device
  * @RFKILL_OP_CHANGE_ALL: userspace changes all devices (of a type, or=
 all)
+ * into a state which also updates the default state for hotplugged de=
vices.
  */
 enum rfkill_operation {
 	RFKILL_OP_ADD =3D 0,
--=20
2.5.0
