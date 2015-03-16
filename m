From: Siva Mannem <siva.mannem.lnx@gmail.com>
Subject: [PATCH net-next v4 0/3] bridge FDB ageing time.
Date: Tue, 17 Mar 2015 04:32:41 +0530
Message-ID: <cover.1426509272.git.siva.mannem.lnx@gmail.com>
Cc: davem@davemloft.net, sfeldma@gmail.com,
	Siva Mannem <siva.mannem.lnx@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33628 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933157AbbCPXDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 19:03:03 -0400
Received: by pagr17 with SMTP id r17so78194646pag.0
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 16:03:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v4:
Changes based on review comments.
  - Validate all netlink attributes and return error if any of the    
    validation fails.
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

Siva Mannem (3):
  Configure bridge FDB ageing time using netlink.
  
  Ensure that the newly configured FDB ageing time becomes effective
  immediately. It also makes the behavior consistent when the ageing_timer is
  set using any of the three existing mechanisms(sysfs, ioctl, netlink).
  
  Validate all netlink attributes and return error if any of the    
  validation fails.

 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_device.c       | 17 ++++++++++++++
 net/bridge/br_ioctl.c        |  3 +--
 net/bridge/br_netlink.c      | 53 +++++++++++++++++++++++++++++++++++++++++---
 net/bridge/br_private.h      |  5 +++++
 net/bridge/br_sysfs_br.c     |  8 +------
 6 files changed, 75 insertions(+), 12 deletions(-)

-- 
2.1.0
