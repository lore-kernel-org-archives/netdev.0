From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v6 net-next 15/17] dt-bindings: slave-device: add current-speed property
Date: Tue, 23 May 2017 15:12:51 +0200
Message-ID: <1495545173-22150-16-git-send-email-stefan.wahren@i2se.com>
References: <1495545173-22150-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Jakub Kicinski <kubakici@wp.pl>, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:63943 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967523AbdEWNOr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 09:14:47 -0400
In-Reply-To: <1495545173-22150-1-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a new DT property to define the current baud rate of the
slave device.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
Reviewed-by: Rob Herring <robh@kernel.org>
---
 Documentation/devicetree/bindings/serial/slave-device.txt | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/Documentation/devicetree/bindings/serial/slave-device.txt b/Documentation/devicetree/bindings/serial/slave-device.txt
index f660379..40110e0 100644
--- a/Documentation/devicetree/bindings/serial/slave-device.txt
+++ b/Documentation/devicetree/bindings/serial/slave-device.txt
@@ -21,6 +21,15 @@ Optional Properties:
 		  can support. For example, a particular board has some signal
 		  quality issue or the host processor can't support higher
 		  baud rates.
+- current-speed	: The current baud rate the device operates at. This should
+		  only be present in case a driver has no chance to know
+		  the baud rate of the slave device.
+		  Examples:
+		    * device supports auto-baud
+		    * the rate is setup by a bootloader and there is no
+		      way to reset the device
+		    * device baud rate is configured by its firmware but
+		      there is no way to request the actual settings
 
 Example:
 
-- 
2.1.4
