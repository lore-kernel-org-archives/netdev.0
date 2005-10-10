From: "Alejandro Bonilla" <abonilla@linuxwireless.org>
Subject: [PATCH] Documentation/networking/README.ipw2100
Date: Mon, 10 Oct 2005 13:05:11 -0400
Message-ID: <20051010165917.M60859@linuxwireless.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=iso-8859-1
Cc: netdev@vger.kernel.org, jketreno@linux.intel.com, jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750955AbVJJRFQ@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This updates the Documentation so that IPW2100 can be well documented for
2.6.14, the Kconfig points to this file but there is no information about the
firmware.

Please apply.

Signed-off-by: Alejandro Bonilla <abonilla@linuxwireless.org>


diff --git a/Documentation/networking/README.ipw2100
b/Documentation/networking/README.ipw2100
--- a/Documentation/networking/README.ipw2100
+++ b/Documentation/networking/README.ipw2100
@@ -143,7 +143,12 @@ firmware image to load into the wireless
 
 You can obtain these images from <http://ipw2100.sf.net/firmware.php>.
 
-See INSTALL for instructions on installing the firmware.
+The firmware package should be extracted where your hotplug firmware agent
+is looking:
+
+% grep FIRMWARE /etc/hotplug/firmware.agent
+
+The most common path is /lib/firmware but the firmware.agent will tell.
 
 
 ===========================
