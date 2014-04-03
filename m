From: =?UTF-8?q?Cristian=20Rodr=C3=ADguez?= <crrodriguez@opensuse.org>
Subject: [PATCH ethtool 1/2] ixgbe: missing "static" in function definition
Date: Thu,  3 Apr 2014 00:06:15 -0300
Message-ID: <1396494376-6521-1-git-send-email-crrodriguez@opensuse.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ben@decadent.org.uk,
	=?UTF-8?q?Cristian=20Rodr=C3=ADguez?= <crrodriguez@opensuse.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:62865 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932869AbaDCDGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 23:06:45 -0400
Received: by mail-qc0-f171.google.com with SMTP id c9so1241935qcz.30
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 20:06:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Cristian Rodr=C3=ADguez <crrodriguez@opensuse.org>
---
 ixgbe.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ixgbe.c b/ixgbe.c
index 6a663e4..3928d77 100644
--- a/ixgbe.c
+++ b/ixgbe.c
@@ -76,7 +76,7 @@ enum ixgbe_mac_type {
 	ixgbe_num_macs
 };
=20
-enum ixgbe_mac_type
+static enum ixgbe_mac_type
 ixgbe_get_mac_type(u16 device_id)
 {
 	enum ixgbe_mac_type mac_type =3D ixgbe_mac_unknown;
--=20
1.8.4.5
