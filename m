From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v5 14/17] dt-bindings: slave-device: add current-speed property
Date: Wed, 10 May 2017 10:53:25 +0200
Message-ID: <1494406408-31760-15-git-send-email-stefan.wahren@i2se.com>
References: <1494406408-31760-1-git-send-email-stefan.wahren@i2se.com>
Cc: Mark Rutland <mark.rutland@arm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494406408-31760-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds a new DT property to define the current baud rate of the
slave device.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
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
