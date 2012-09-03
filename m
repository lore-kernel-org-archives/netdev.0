From: Alan Ott <alan@signal11.us>
Subject: [PATCH v7 0/1] Driver for Microchip MRF24J40
Date: Sun,  2 Sep 2012 21:44:12 -0400
Message-ID: <1346636653-28903-1-git-send-email-alan@signal11.us>
References: <1346300194-3286-1-git-send-email-alan@signal11.us>
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Alan Ott <alan@signal11.us>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tony Cheneau <tony.cheneau@amnesiak.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1346300194-3286-1-git-send-email-alan@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a driver for the Microchip MRF24J40 802.15.4 transceiver.

This is the same as v6 except that it now puts the driver in
drivers/net/ieee802154 instead of drivers/ieee802154, since
drivers/ieee802154 was recently moved to drivers/net/ieee802154 in
0739d643b8dda866d1011bcf

Full history and discussion can be found on the archives of the linux-zigbee
mailing list:

http://www.mail-archive.com/linux-zigbee-devel@lists.sourceforge.net/msg01014.html

Alan Ott (1):
  ieee802154: MRF24J40 driver

 drivers/net/ieee802154/Kconfig    |  11 +
 drivers/net/ieee802154/Makefile   |   1 +
 drivers/net/ieee802154/mrf24j40.c | 767 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 779 insertions(+)
 create mode 100644 drivers/net/ieee802154/mrf24j40.c

-- 
1.7.11.2
