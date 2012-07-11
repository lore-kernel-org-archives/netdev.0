From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH firmware] rtl_nic: update firmware for RTL8168G
Date: Wed, 11 Jul 2012 20:10:03 +0800
Message-ID: <1342008603-1279-1-git-send-email-hayeswang@realtek.com>
References: <1341878937.25597.309.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <dwmw2@infradead.org>, <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341878937.25597.309.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46ile: rtl_nic/rtl8168g-1.fw
Version: 0.0.2

Change the ocp_base of linux driver to OCP_STD_PHY_BASE after setting
firmware. The firmware would modify the ocp_base, and that results the
driver uses the wrong ocp_base to access standard phy after setting
firmware.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 WHENCE                |    2 +-
 rtl_nic/rtl8168g-1.fw |  Bin 4272 -> 4272 bytes
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/WHENCE b/WHENCE
index 1fb7951..f46c842 100644
--- a/WHENCE
+++ b/WHENCE
@@ -1817,7 +1817,7 @@ File: rtl_nic/rtl8106e-1.fw
 Version: 0.0.1
=20
 File: rtl_nic/rtl8168g-1.fw
-Version: 0.0.1
+Version: 0.0.2
=20
 Licence:
  * Copyright =C2=A9 2011, Realtek Semiconductor Corporation
diff --git a/rtl_nic/rtl8168g-1.fw b/rtl_nic/rtl8168g-1.fw
index dace1ea98c66de08107ee0857d8a8680d57d7898..bc03a5d28fd07d99a6cc89a=
a115d8ef8942629a6 100644
GIT binary patch
delta 78
zcmdm>xIs~u0SJmpax4tZEYfui;|=3Dr-^o$e?%=3DHZo^$m?cl0c9E#6m0#40#iERoN}A
WOw6oI3^qo33-CB_$u|JyzyJVS1PxdK

delta 78
zcmdm>xIs~u0SJmpax4tZEYfui;|=3Dr-^b8dY%=3DC>c^$m?cl0c9E#DXjg3}F*>RoTs~
Qj7)%NW2CnL4@eRQ08i5lSO5S3

--=20
1.7.10.4
