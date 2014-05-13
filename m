From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next 0/5] 802154: some cleanups and fixes
Date: Tue, 13 May 2014 19:24:01 +0200
Message-ID: <1400001846-5349-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:39672 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057AbaEMRYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 13:24:24 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s4DHOLnt024087
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 13 May 2014 19:24:21 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds some definitions for 802.15.4 header fields that were missing,
changes 6lowpan packet size calculation to always be correct and fixes a bug in
802.15.4 dgram sockets where sockets would ignore arguments to sendmsg(). Also,
a few minor changes to mac_cb handling, and mark a single-use function static.

---

Phoebe Buckheister (5):
      ieee802154: add definitions for link-layer security and header functions
      6lowpan: simplify/fix payload length calculation
      ieee802154: change _cb handling slightly
      ieee802154: don't ignore "to" argument in unbound dgram sendmsg
      mac802154: make mac802154_wpan_open static


 include/net/ieee802154.h        |    9 +++++++
 include/net/ieee802154_netdev.h |   54 ++++++++++++++++++++++++++-------------
 net/ieee802154/6lowpan_rtnl.c   |   33 ++++++++++++++----------
 net/ieee802154/dgram.c          |   23 +++++++++++------
 net/ieee802154/header_ops.c     |   52 ++++++++++++++++++++++++++++++++-----
 net/mac802154/rx.c              |    2 --
 net/mac802154/wpan.c            |   28 ++++++++++----------
 7 files changed, 139 insertions(+), 62 deletions(-)
