From: petkan@nucleusys.com
Subject: [Fwd: pegasus usb net driver]
Date: Fri, 14 Aug 2009 19:40:48 +0300 (EEST)
Message-ID: <98be570d7bcf50bef64ffbd1c3479004.squirrel@nucleusys.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;boundary="----=_20090814194048_21531"
Cc: "Junya Enoki" <jenoki@mac.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([78.83.248.164]:47768 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755311AbZHNRON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 13:14:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_20090814194048_21531
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit

        Hi Dave,

Attached is a patch against 2.6.30.4 and below is the description.  Please
apply.


                Petko

---------------------------- Original Message ----------------------------
Subject: pegasus driver
From:    "Junya Enoki" <jenoki@mac.com>
Date:    Thu, August 13, 2009 5:59 am
To:      petkan@users.sourceforge.net
--------------------------------------------------------------------------

hi,

Please Add new definition to 'pegasus.h'
for support Japanese IO DATA "ETX-US2" USB Ethernet Adapter.

PEGASUS_DEV( “IO DATA USB ETX-US2”, VENDOR_IODATA, 0x092a,
DEFAULT_GPIO_RESET | PEGASUS_II )

ZZzz...
Junya Enoki jenoki@mac.com


------=_20090814194048_21531
Content-Type: text/x-diff; name="pegasus.patch"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename="pegasus.patch"

--- drivers/net/usb/pegasus.h-orig	2009-08-14 16:03:57.000000000 +0300
+++ drivers/net/usb/pegasus.h	2009-08-14 16:05:39.000000000 +0300
@@ -250,6 +250,8 @@ PEGASUS_DEV( "IO DATA USB ET/TX", VENDOR
 		DEFAULT_GPIO_RESET )
 PEGASUS_DEV( "IO DATA USB ET/TX-S", VENDOR_IODATA, 0x0913,
 		DEFAULT_GPIO_RESET | PEGASUS_II )
+PEGASUS_DEV( "IO DATA USB ETX-US2", VENDOR_IODATA, 0x092a,
+		DEFAULT_GPIO_RESET | PEGASUS_II )
 PEGASUS_DEV( "Kingston KNU101TX Ethernet", VENDOR_KINGSTON, 0x000a,
 		DEFAULT_GPIO_RESET)
 PEGASUS_DEV( "LANEED USB Ethernet LD-USB/TX", VENDOR_LANEED, 0x4002,
------=_20090814194048_21531--


