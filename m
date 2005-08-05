From: Mateusz Berezecki <mateuszb@gmail.com>
Subject: atheros driver (1/8)
Date: Fri, 05 Aug 2005 04:57:17 +0200
Message-ID: <42F2D58D.8040807@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030408030905030800040107"
Cc: netdev <netdev@vger.kernel.org>
Return-path: <kernel-mentors-bounces@selenic.com>
To: kernel-mentors@selenic.com
List-Unsubscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=unsubscribe>
List-Archive: <http://www.selenic.com/pipermail/kernel-mentors>
List-Post: <mailto:kernel-mentors@selenic.com>
List-Help: <mailto:kernel-mentors-request@selenic.com?subject=help>
List-Subscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=subscribe>
Sender: kernel-mentors-bounces@selenic.com
Errors-To: kernel-mentors-bounces@selenic.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030408030905030800040107
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit



--------------030408030905030800040107
Content-Type: text/x-patch;
 name="atheros5212-1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="atheros5212-1.patch"

--- netdev-2.6.git#ieee80211/drivers/net/wireless/Kconfig	2005-08-02 13:18:21.000000000 +0200
+++ netdev-atheros/drivers/net/wireless/Kconfig	2005-08-05 03:43:32.000000000 +0200
@@ -459,6 +459,14 @@ config PRISM54
 	  say M here and read <file:Documentation/modules.txt>.  The module
 	  will be called prism54.ko.
 
+comment "Atheros combo cardbus cards support"
+config PCMCIA_ATHEROS_5212
+	tristate "Atheros 5212 (a/b/g) combo cards"
+	depends on NET_RADIO && EXPERIMENTAL && PCMCIA
+	---help---
+	  Experimental support for Atheros radio chips.
+
+					
 # yes, this works even when no drivers are selected
 config NET_WIRELESS
 	bool
diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/Makefile netdev-atheros/drivers/net/wireless/Makefile
--- netdev-2.6.git#ieee80211/drivers/net/wireless/Makefile	2005-08-02 13:18:22.000000000 +0200
+++ netdev-atheros/drivers/net/wireless/Makefile	2005-08-05 03:48:17.000000000 +0200
@@ -35,3 +35,5 @@ obj-$(CONFIG_PRISM54)		+= prism54/
 # 16-bit wireless PCMCIA client drivers
 obj-$(CONFIG_PCMCIA_RAYCS)	+= ray_cs.o
 obj-$(CONFIG_PCMCIA_WL3501)	+= wl3501_cs.o
+
+obj-$(CONFIG_PCMCIA_ATHEROS_5212) += atheros/atheros5212/
diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/Makefile netdev-atheros/drivers/net/wireless/atheros/atheros5212/Makefile
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/Makefile	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/Makefile	2005-08-05 03:51:53.000000000 +0200
@@ -0,0 +1,3 @@
+atheros5212-objs := init.o eeprom.o beacons.o powermodes.o keys.o mode_tables.o regops.o interrupts.o caps.o chans.o transmit_receive.o mode_tables.o other.o ioctl.o
+
+obj-$(CONFIG_PCMCIA_ATHEROS_5212) += atheros5212.o


--------------030408030905030800040107
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Kernel-mentors mailing list
Kernel-mentors@selenic.com
http://selenic.com/mailman/listinfo/kernel-mentors

--------------030408030905030800040107--
