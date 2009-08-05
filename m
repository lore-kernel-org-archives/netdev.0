From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [GIT PULL 0/3] IEEE 802.15.4 last-minute fixes v2
Date: Wed,  5 Aug 2009 11:28:14 +0400
Message-ID: <1249457297-8355-1-git-send-email-dbaryshkov@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergey Lapin <slapin@ossfans.org>,
	linux-zigbee-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:55848 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933280AbZHEH2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 03:28:48 -0400
Received: by fxm17 with SMTP id 17so3713972fxm.37
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2009 00:28:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull several minor fixes for the IEEE 802.15.4 stack.

The following changes since commit db71789c01ae7b641f83c5aa64e7df25122f4b28:
  David S. Miller (1):
        xfrm6: Fix xfrm6_policy.c build when SYSCTL disabled.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/lowpan/lowpan.git for-linus

Dmitry Eremin-Solenikov (3):
      af_ieee802154: fix ioctl processing
      af_ieee802154: provide dummy get/setsockopt
      documentation: fix wrt. headers rename

 Documentation/networking/ieee802154.txt |    9 ++++-----
 net/ieee802154/af_ieee802154.c          |    8 +++++---
 net/ieee802154/dgram.c                  |   14 ++++++++++++++
 net/ieee802154/raw.c                    |   14 ++++++++++++++
 4 files changed, 37 insertions(+), 8 deletions(-)

-- 
With best wishes
Dmitry Eremin-Solenikov
