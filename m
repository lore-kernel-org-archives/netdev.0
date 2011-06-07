From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 0/2] speed up net device allocation using pattern names
Date: Tue,  7 Jun 2011 04:39:44 +0300
Message-ID: <1307410786-19110-1-git-send-email-lucian.grijincu@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51773 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755997Ab1FGBj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 21:39:59 -0400
Received: by wya21 with SMTP id 21so3213782wya.19
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 18:39:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The next two patches:
- add a faster way to add net devices using pattern names like "dummy%d"
- call that routine for dummy

Patches are against net-next, but should apply cleanly to 3.0-rc1 too.

Lucian Adrian Grijincu (2):
  net: add alloc_netdev_mqs_id
  net: dummy: allocate devices with alloc_netdev_id

 drivers/net/dummy.c       |    4 ++-
 include/linux/netdevice.h |    7 +++++
 net/core/dev.c            |   63 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 73 insertions(+), 1 deletions(-)

-- 
1.7.5.2.317.g391b14

