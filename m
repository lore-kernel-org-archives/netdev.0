From: Robert Olsson <robert@herjulf.net>
Subject: Diagnostic Monitoring Interface Monitoring (DOM) PATCH 0/5 for net-next-2.6
Date: Mon, 23 Nov 2009 23:45:40 +0100
Message-ID: <19211.4244.135603.458550@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robert@herjulf.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from av8-1-sn3.vrr.skanova.net ([81.228.9.183]:41719 "EHLO
	av8-1-sn3.vrr.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752872AbZKWWpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 17:45:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here are basic support to bring Diagnostic Monitoring Interface Monitoring (DOM)
to Linux this is more or less mandatory when building optical networks.

Optical modules as SFP, SFP+, XFP, GBIC etc holds transceiver and link diagnostic 
data needed to monitor and troubleshoot optical links, Talks to networks cards
via the I2C-bus (DOM lives in memory page 0xA2).

In essential:

Usage example: ethtool -D eth5 

Ext-Calbr: Avr RX-Power: Alarm & Warn: RX_LOS:         Wavelength: 1310 nm
Alarms, warnings in beginning of line, Ie. AH = Alarm High, WL == Warn Low etc
       Temp:  35.9 C                   Thresh: Lo: -12.0/-8.0   Hi: 103.0/110.0 C
       Vcc:  3.33 V                    Thresh: Lo:   3.0/3.0    Hi:   3.7/4.0   V
       Tx-Bias:  13.4 mA               Thresh: Lo:   2.0/4.0    Hi:  70.0/84.0  mA
ALWL   TX-pwr:  -5.9 dBm ( 0.26 mW)    Thresh: Lo:  -4.0/-2.0   Hi:   7.0/8.2   dBm
AHWH   RX-pwr:  -5.0 dBm ( 0.31 mW)    Thresh: Lo: -35.2/-28.0  Hi:  -8.2/-6.0  dBm

Read more in Documentation/networking/dom.txt

It's tested with the igb driver, there is also a patch for the ixgbe driver but I 
haven't any SFP+ with DOM support yet.


There are room for improvements an clean-ups. 

Cheers
						--ro




