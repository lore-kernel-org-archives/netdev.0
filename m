From: Andrew Morton <akpm@linux-foundation.org>
Subject: s390 allmodconfig
Date: Fri, 2 Mar 2007 00:18:11 -0800
Message-ID: <20070302001811.b103e2b2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>,
	Richard Purdie <rpurdie@rpsys.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:48578 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161323AbXCBITE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 03:19:04 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Not sure who to blame for all of this...

net/bluetooth/hidp/Kconfig:4:warning: 'select' used by config symbol 'BT_HIDP' refer to undefined symbol 'HID'
net/mac80211/Kconfig:17:warning: 'select' used by config symbol 'MAC80211_LEDS' refer to undefined symbol 'NEW_LEDS'
net/mac80211/Kconfig:18:warning: 'select' used by config symbol 'MAC80211_LEDS' refer to undefined symbol 'LEDS_TRIGGERS'
drivers/net/Kconfig:1435:warning: 'select' used by config symbol 'B44' refer to undefined symbol 'SSB'
drivers/net/wireless/bcm43xx/Kconfig:5:warning: 'select' used by config symbol 'BCM43XX' refer to undefined symbol 'HW_RANDOM'
drivers/net/wireless/mac80211/bcm43xx/Kconfig:13:warning: 'select' used by config symbol 'BCM43XX_MAC80211_PCI' refer to undefined symbol 'SSB_PCIHOST'
drivers/net/wireless/mac80211/bcm43xx/Kconfig:14:warning: 'select' used by config symbol 'BCM43XX_MAC80211_PCI' refer to undefined symbol 'SSB_DRIVER_PCICORE'
drivers/net/wireless/mac80211/bcm43xx/Kconfig:27:warning: 'select' used by config symbol 'BCM43XX_MAC80211_PCMCIA' refer to undefined symbol 'SSB_PCMCIAHOST'
drivers/net/wireless/mac80211/bcm43xx/Kconfig:5:warning: 'select' used by config symbol 'BCM43XX_MAC80211' refer to undefined symbol 'SSB'
