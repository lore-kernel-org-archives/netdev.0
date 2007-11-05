From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] remove Documentation/networking/Configurable
Date: Mon, 5 Nov 2007 18:05:11 +0100
Message-ID: <20071105170510.GR12045@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:59440 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756161AbXKERFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 12:05:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After more than 11 years this file does no longer contain much useful 
information.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 Documentation/networking/00-INDEX     |    2 -
 Documentation/networking/Configurable |   34 --------------------------
 2 files changed, 36 deletions(-)

f200fa4962996e11967e7c1040771b6669829fca 
diff --git a/Documentation/networking/00-INDEX b/Documentation/networking/00-INDEX
index c48892e..a9f4acc 100644
--- a/Documentation/networking/00-INDEX
+++ b/Documentation/networking/00-INDEX
@@ -4,8 +4,6 @@
 	- information on the 3Com EtherLink Plus (3c505) driver.
 6pack.txt
 	- info on the 6pack protocol, an alternative to KISS for AX.25
-Configurable
-	- info on some of the configurable network parameters
 DLINK.txt
 	- info on the D-Link DE-600/DE-620 parallel port pocket adapters
 PLIP.txt
diff --git a/Documentation/networking/Configurable b/Documentation/networking/Configurable
deleted file mode 100644
index 69c0dd4..0000000
--- a/Documentation/networking/Configurable
+++ /dev/null
@@ -1,34 +0,0 @@
-
-There are a few network parameters that can be tuned to better match
-the kernel to your system hardware and intended usage. The defaults
-are usually a good choice for 99% of the people 99% of the time, but
-you should be aware they do exist and can be changed.
-
-The current list of parameters can be found in the files:
-
-	linux/net/TUNABLE
-	Documentation/networking/ip-sysctl.txt
-
-Some of these are accessible via the sysctl interface, and many more are
-scheduled to be added in this way. For example, some parameters related 
-to Address Resolution Protocol (ARP) are very easily viewed and altered.
-
-	# cat /proc/sys/net/ipv4/arp_timeout
-	6000
-	# echo 7000 > /proc/sys/net/ipv4/arp_timeout
-	# cat /proc/sys/net/ipv4/arp_timeout
-	7000
-
-Others are already accessible via the related user space programs.
-For example, MAX_WINDOW has a default of 32 k which is a good choice for
-modern hardware, but if you have a slow (8 bit) Ethernet card and/or a slow
-machine, then this will be far too big for the card to keep up with fast 
-machines transmitting on the same net, resulting in overruns and receive errors.
-A value of about 4 k would be more appropriate, which can be set via:
-
-	# route add -net 192.168.3.0 window 4096
-
-The remainder of these can only be presently changed by altering a #define
-in the related header file. This means an edit and recompile cycle.
-
-						Paul Gortmaker 06/96

