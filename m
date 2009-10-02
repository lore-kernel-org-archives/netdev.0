From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 0/4] More device type integration
Date: Fri,  2 Oct 2009 17:15:24 +0200
Message-ID: <cover.1254495724.git.marcel@holtmann.org>
Cc: David Miller <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Greg KH <greg@kroah.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:33417 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754175AbZJBPPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 11:15:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I followed the work from Johannes and made sure we can register the
device type for wireless devices via the netdev notifier callback for
all cfg80211 based devices. This way we don't have to touch any of
the drivers.

For the mobile broadband cards from Ericsson, the device type is now
set to "wwan" and it also uses "wwan%d" for the default interface name.

Regards

Marcel


Johannes Berg (1):
  net: introduce NETDEV_POST_INIT notifier

Marcel Holtmann (3):
  usbnet: Use wwan%d interface name for mobile broadband devices
  usbnet: Set device type for wlan and wwan devices
  cfg80211: assign device type in netdev notifier callback

 drivers/net/usb/cdc_ether.c |   20 ++++++++++++++------
 drivers/net/usb/usbnet.c    |   17 +++++++++++++++++
 include/linux/notifier.h    |    1 +
 include/linux/usb/usbnet.h  |    1 +
 net/core/dev.c              |    6 ++++++
 net/mac80211/iface.c        |    5 -----
 net/wireless/core.c         |    7 +++++++
 7 files changed, 46 insertions(+), 11 deletions(-)

