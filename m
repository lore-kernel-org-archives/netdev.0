From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH RFC] ZyDAS ZD1211 USB-WLAN driver
Date: Sat, 03 Jun 2006 12:20:35 +0100
Message-ID: <44817083.508@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ulrich Kunitz <kune@deine-taler.de>,
	USB development list <linux-usb-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:29276 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932610AbWFCLUS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jun 2006 07:20:18 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I tried to submit this patch yesterday, but it doesn't appear to have 
been delivered. The patch is probably a bit on the large side, so I'll 
try again over http:

http://dev.gentoo.org/~dsd/kernel/zd1211rw.patch

Any comments appreciated.

[PATCH RFC] ZyDAS ZD1211 USB-WLAN driver

There are 60+ USB wifi adapters available on the market based on the 
ZyDAS ZD1211 chip.

Unlike the predecessor (ZD1201), ZD1211 does not have a hardware MAC, so 
most data operations are coordinated by the device driver. The ZD1211 
chip sits alongside an RF transceiver which is also controlled by the 
driver. Our driver currently supports 2 RF types, we know of one other 
available in a few marketed products which we will be supporting soon.

Our driver also supports the newer revision of ZD1211, called ZD1211B. 
The initialization and RF operations are slightly different for the new 
revision, but the main difference is 802.11e support. Our driver does 
not support the QoS features yet, but we think we know how to use them.

This driver is based on ZyDAS's own GPL driver available from 
www.zydas.com.tw. ZyDAS engineers have been responsive and supportive of 
our efforts, so thumbs up to them. Additionally, the firmware is 
redistributable and they have provided device specs.

This driver has been written primarily by Ulrich Kunitz and myself. 
Graham Gower, Greg KH, Remco and Bryan Rittmeyer have also contributed. 
The developers of ieee80211 and softmac have made our lives so much 
easier- thanks!

We maintain a small info-page: http://zd1211.ath.cx/wiki/DriverRewrite

If there is enough time for review, we would like to aim for inclusion 
in 2.6.18. The driver works nicely as a STA, and can connect to both 
open and encrypted networks (we are using software-based encryption for 
now). We will work towards supporting more advanced features in the 
future (ad-hoc, master mode, 802.11a, ...).

Signed-off-by: Daniel Drake <dsd@gentoo.org>
