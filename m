From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 01/27] Documentation/networking/e1000.txt: Update documentation
Date: Fri, 10 Dec 2010 22:16:55 -0800
Message-ID: <1292048241-22026-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1292048241-22026-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:44432
	"EHLO qmta14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750736Ab0LKGRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 01:17:37 -0500
To: davem@davemloft.net
In-Reply-To: <1292048241-22026-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update Intel Wired LAN e1000 documentation.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 Documentation/networking/e1000.txt |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/e1000.txt b/Documentation/networking/e1000.txt
index d9271e7..6cb13e9 100644
--- a/Documentation/networking/e1000.txt
+++ b/Documentation/networking/e1000.txt
@@ -79,7 +79,7 @@ InterruptThrottleRate
 ---------------------
 (not supported on Intel(R) 82542, 82543 or 82544-based adapters)
 Valid Range:   0,1,3,4,100-100000 (0=off, 1=dynamic, 3=dynamic conservative,
-                                   4=simplified balancing)
+                                 4=simplified balancing)
 Default Value: 3
 
 The driver can limit the amount of interrupts per second that the adapter
@@ -124,8 +124,8 @@ InterruptThrottleRate is set to mode 1. In this mode, which operates
 the same as mode 3, the InterruptThrottleRate will be increased stepwise to
 70000 for traffic in class "Lowest latency".
 
-In simplified mode the interrupt rate is based on the ratio of Tx and
-Rx traffic.  If the bytes per second rate is approximately equal, the
+In simplified mode the interrupt rate is based on the ratio of TX and
+RX traffic.  If the bytes per second rate is approximately equal, the
 interrupt rate will drop as low as 2000 interrupts per second.  If the
 traffic is mostly transmit or mostly receive, the interrupt rate could
 be as high as 8000.
@@ -245,7 +245,7 @@ NOTE:  Depending on the available system resources, the request for a
 TxDescriptorStep
 ----------------
 Valid Range:    1 (use every Tx Descriptor)
-		4 (use every 4th Tx Descriptor)
+                4 (use every 4th Tx Descriptor)
 
 Default Value:  1 (use every Tx Descriptor)
 
@@ -312,7 +312,7 @@ Valid Range:   0-xxxxxxx (0=off)
 Default Value: 256
 Usage: insmod e1000.ko copybreak=128
 
-Driver copies all packets below or equaling this size to a fresh Rx
+Driver copies all packets below or equaling this size to a fresh RX
 buffer before handing it up the stack.
 
 This parameter is different than other parameters, in that it is a
-- 
1.7.3.2

