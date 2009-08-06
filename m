From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [GIT PULL 0/2] IEEE 802.15.4 last-minute fixes v3
Date: Thu,  6 Aug 2009 16:26:24 +0400
Message-ID: <1249561586-26927-1-git-send-email-dbaryshkov@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergey Lapin <slapin@ossfans.org>,
	linux-zigbee-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:26111 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752931AbZHFM1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 08:27:02 -0400
Received: by ey-out-2122.google.com with SMTP id 9so334141eyd.37
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2009 05:27:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I hope in this try I don't make any mistakes...

The following changes since commit 0bf52b981770cbf006323bab5177f2858a196766:
  Ingo Molnar (1):
        net: Fix spinlock use in alloc_netdev_mq()

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/lowpan/lowpan.git for-linus

Dmitry Eremin-Solenikov (2):
      af_ieee802154: fix ioctl processing
      af_ieee802154: provide dummy get/setsockopt

 net/ieee802154/af_ieee802154.c |    8 +++++---
 net/ieee802154/dgram.c         |   14 ++++++++++++++
 net/ieee802154/raw.c           |   14 ++++++++++++++
 3 files changed, 33 insertions(+), 3 deletions(-)
