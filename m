From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH 2/2] Ethtool: add EEE to ethtool's documentation
Date: Tue, 5 Jun 2012 09:41:10 +0300
Message-ID: <1338878470-24784-3-git-send-email-yuvalmin@broadcom.com>
References: <1338878470-24784-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, peppe.cavallaro@st.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: bhutchings@solarflare.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1390 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752750Ab2FEGmz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2012 02:42:55 -0400
In-Reply-To: <1338878470-24784-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

under Synopsis:
	ethtool --get-eee devname
	ethtool --set-eee devname [eee on|off] [tx-lpi on|off] [tx-timer N] [advertise N]

under Options:
       --get-eee
              Queries  the  specified network device for its support in Efficient Energy Ethernet (ac-
	      cording to the IEEE 802.3az specifications)
       --set-eee
	      Sets the device EEE behaviour.
       eee on|off
	      Enables/Disables the device support in EEE.
       tx-lpi on|off
	      Determines whether the device should assert its tx lpi.
       advertise N
              Sets the speeds for which the device would advertise EEE capabliities.   Values  are  as
	      for --change advertise
       tx-timer N
              Sets  the  amount  of time the device should stay in idle mode prior to asserting its tx
              lpi (in microseconds). This has meaning only when tx lpi is on.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 ethtool.8.in |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 523b737..b906d8e 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -335,6 +335,16 @@ ethtool \- query or control network driver and hardware settings
 .I devname flag
 .A1 on off
 .RB ...
+.HP
+.B ethtool \-\-get\-eee
+.I devname
+.HP
+.B ethtool \-\-set\-eee
+.I devname
+.B2 eee on off
+.B2 tx-lpi on off
+.BN tx-timer
+.BN advertise
 .
 .\" Adjust lines (i.e. full justification) and hyphenate.
 .ad
@@ -817,6 +827,28 @@ Sets the device's private flags as specified.
 .I flag
 .A1 on off
 Sets the state of the named private flag.
+.TP
+.B \-\-get\-eee
+Queries the specified network device for its support in Efficient Energy
+Ethernet (according to the IEEE 802.3az specifications)
+.TP
+.B \-\-set\-eee
+Sets the device EEE behaviour.
+.TP
+.A2 eee on off
+Enables/Disables the device support in EEE.
+.TP
+.A2 tx-lpi on off
+Determines whether the device should assert its tx lpi.
+.TP
+.BI advertise \ N
+Sets the speeds for which the device would advertise EEE capabliities.
+Values are as for
+.B \-\-change advertise
+.TP
+.BI tx-timer \ N
+Sets the amount of time the device should stay in idle mode prior to asserting
+its tx lpi (in microseconds). This has meaning only when tx lpi is on.
 .SH BUGS
 Not supported (in part or whole) on all network drivers.
 .SH AUTHOR
-- 
1.7.9.rc2
