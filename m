From: Xose Vazquez Perez <xose@wanadoo.es>
Subject: [PATCH]  detailled bcm help-2.4.25
Date: Mon, 23 Feb 2004 14:31:22 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <403A00AA.3010707@wanadoo.es>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060802080702010002080104"
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@redhat.com, netdev@oss.sgi.com, marcelo.tosatti@cyclades.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060802080702010002080104
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


aginst 2.4.25

This patch adds more realistic information about bcm NICs.
People only know the commercial names and not about chips names.

-- 
x86-64 GenuineIntel


--------------060802080702010002080104
Content-Type: text/plain;
 name="bcm-help.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bcm-help.diff"

--- linux-2.4.25/Documentation/Configure.help	2004-02-05 23:00:09.000000000 +0100
+++ n/Documentation/Configure.help	2004-02-23 14:28:05.000000000 +0100
@@ -11859,7 +11859,7 @@
 
 Broadcom Tigon3 support
 CONFIG_TIGON3
-  This driver supports Broadcom Tigon3 based gigabit Ethernet cards.
+  This driver supports Broadcom NetXtreme BCM570X based gigabit Ethernet cards.
 
   If you want to compile this driver as a module ( = code which can be
   inserted in and removed from the running kernel whenever you want),
@@ -12348,9 +12348,7 @@
 
 Broadcom 4400 ethernet support (EXPERIMENTAL)
 CONFIG_B44
-  If you have a network (Ethernet) controller of this type, say Y and
-  read the Ethernet-HOWTO, available from
-  <http://www.tldp.org/docs.html#howto>.
+  This driver supports Broadcom BCM440X based 10/100 Ethernet cards.
 
   If you want to compile this as a module ( = code which can be
   inserted in and removed from the running kernel whenever you want),

--------------060802080702010002080104--
