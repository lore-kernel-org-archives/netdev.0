From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 0/2] net: allow to change carrier via sysfs
Date: Tue, 30 Aug 2011 16:46:46 +0200
Message-ID: <1314715608-978-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43220 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754280Ab1H3Oqy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 10:46:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As suggested by Ben Hutchings I made "carrier" attribute writeable.
With this patchset one can set carrier on/off on dummy. Might by also handy
to implement this for other devices.

Jiri Pirko (2):
  net: allow to change carrier via sysfs
  dummy: implement carrier change

 drivers/net/dummy.c       |   10 ++++++++++
 include/linux/netdevice.h |    4 ++++
 net/core/dev.c            |   19 +++++++++++++++++++
 net/core/net-sysfs.c      |   26 +++++++++++++++++++++++++-
 4 files changed, 58 insertions(+), 1 deletions(-)

-- 
1.7.6
