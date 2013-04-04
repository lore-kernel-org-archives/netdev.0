From: Werner Almesberger <werner@almesberger.net>
Subject: [PATCH net-next 0/2] ieee802154_mlme_ops oops removal and cleanup
Date: Thu, 4 Apr 2013 13:31:46 -0300
Message-ID: <cover.1365092820.git.werner@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-zigbee-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.openmoko.org ([88.198.124.205]:38752 "EHLO
	mail.openmoko.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762997Ab3DDQcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 12:32:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a kernel oops we get when some linux-zigbee user
space tools try to invoke unimplemented operations.

The second of the two patches checks whether the respective
functions are present and returne EOPNOTSUPP if they aren't.
It also updates the documentation.

The first one removes the unused get_bsn function, which was
a small obstacle for the other patch.

- Werner

Werner Almesberger (2):
  IEEE 802.15.4: remove get_bsn from "struct ieee802154_mlme_ops"
  ieee802154/nl-mac.c: make some MLME operations optional

 Documentation/networking/ieee802154.txt |    5 +++--
 drivers/net/ieee802154/fakehard.c       |   21 ---------------------
 include/net/ieee802154_netdev.h         |    5 ++++-
 net/ieee802154/nl-mac.c                 |   25 ++++++++++++++++++++-----
 4 files changed, 27 insertions(+), 29 deletions(-)

-- 
1.7.10.4
