From: Siva Mannem <siva.mannem.lnx@gmail.com>
Subject: [PATCH net-next v3 0/2] bridge FDB ageing time.
Date: Mon, 16 Mar 2015 12:00:03 +0530
Message-ID: <1426487405-9792-1-git-send-email-siva.mannem.lnx@gmail.com>
Cc: sfeldma@gmail.com, Siva Mannem <siva.mannem.lnx@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34710 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbbCPGaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 02:30:12 -0400
Received: by pacwe9 with SMTP id we9so55581053pac.1
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 23:30:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v3:
Changes based on review comments.
  - Ensure that the newly configured FDB ageing time becomes effective
    immediately and also make the behavior consistent when setting ageing_time
    using any of the existing mechanisms(sysfs, ioctl, netlink).

v2:
  - Added commit message.
  - Fix style problems reported by checkpatch.pl.

v1:
  - Configure bridge FDB ageing time using netlink.

Siva Mannem (2):
  Configure bridge FDB ageing time using netlink.
  
  Ensure that the newly configured FDB ageing time becomes effective
  immediately. It also makes the behavior consistent when the ageing_timer is
  set using any of the three existing mechanisms(sysfs, ioctl, netlink).

 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_device.c       | 17 +++++++++++++++++
 net/bridge/br_ioctl.c        |  3 +--
 net/bridge/br_netlink.c      | 14 ++++++++++++--
 net/bridge/br_private.h      |  5 +++++
 net/bridge/br_sysfs_br.c     |  8 +-------
 6 files changed, 37 insertions(+), 11 deletions(-)

-- 
2.1.0
