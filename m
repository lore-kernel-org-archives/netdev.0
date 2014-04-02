From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH v6 0/4] Provide netdev naming-policy via sysfs
Date: Wed,  2 Apr 2014 11:58:22 +0200
Message-ID: <1396432706-14470-1-git-send-email-dh.herrmann@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Gundersen <teg@jklm.no>,
	Johannes berg <johannes@sipsolutions.net>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kay Sievers <kay.sievers@vrfy.org>,
	David Herrmann <dh.herrmann@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f50.google.com ([209.85.214.50]:45453 "EHLO
	mail-bk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758186AbaDBJ6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 05:58:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This is v6 of the name_assign_type attribute for netdevs. Changes since v5 [1]:
 - Acked-by: Kay Sievers
 - rebased on net-next of today

Aimed for 3.15, but feel free to delay for 3.16 if you want it in -next for some
more time.

Thanks
David

[1] http://thread.gmane.org/gmane.linux.kernel/1673169

David Herrmann (4):
  net: add name_assign_type netdev attribute
  mac80211: set NET_NAME_USER for user-space created ifs
  ath6kl: set NET_NAME_USER for P2P ifs
  brcmfmac: set NET_NAME_USER for P2P ifs

 drivers/net/wireless/ath/ath6kl/cfg80211.c    | 5 ++++-
 drivers/net/wireless/ath/ath6kl/cfg80211.h    | 1 +
 drivers/net/wireless/ath/ath6kl/core.c        | 4 ++--
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c | 1 +
 include/linux/netdevice.h                     | 2 ++
 include/uapi/linux/netdevice.h                | 4 ++++
 net/core/dev.c                                | 7 +++++++
 net/core/net-sysfs.c                          | 2 ++
 net/core/rtnetlink.c                          | 2 ++
 net/mac80211/cfg.c                            | 2 +-
 net/mac80211/ieee80211_i.h                    | 1 +
 net/mac80211/iface.c                          | 2 ++
 net/mac80211/main.c                           | 2 +-
 13 files changed, 30 insertions(+), 5 deletions(-)

-- 
1.9.1
