From: Patrick McHardy <kaber@trash.net>
Subject: [W1]: Remove incorrect MODULE_ALIAS
Date: Sun, 08 Jan 2006 00:44:15 +0100
Message-ID: <43C0524F.1030602@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020006040501050104000605"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161073AbWAGXo5@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020006040501050104000605
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------020006040501050104000605
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[W1]: Remove incorrect MODULE_ALIAS

The w1 netlink socket is created by a hardware specific driver calling
w1_add_master_device, so there is no point in including a module alias
for netlink autoloading in the core.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit a8657adb8c04bbe30544306ec55005a635ba65fd
tree 2c029cf104239958220629d34c76c7290bd99e43
parent b73952761225e41cb81afe157cb312a594a95693
author Patrick McHardy <kaber@trash.net> Sun, 08 Jan 2006 00:42:42 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 08 Jan 2006 00:42:42 +0100

 drivers/w1/w1_int.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/w1/w1_int.c b/drivers/w1/w1_int.c
index c3f67ea..e2920f0 100644
--- a/drivers/w1/w1_int.c
+++ b/drivers/w1/w1_int.c
@@ -217,5 +217,3 @@ void w1_remove_master_device(struct w1_b
 
 EXPORT_SYMBOL(w1_add_master_device);
 EXPORT_SYMBOL(w1_remove_master_device);
-
-MODULE_ALIAS_NET_PF_PROTO(PF_NETLINK, NETLINK_W1);

--------------020006040501050104000605--
