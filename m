From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net v2 0/2] mlxsw: Couple of fixes
Date: Fri, 11 Nov 2016 16:34:24 +0100
Message-ID: <1478878466-3141-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, arkadis@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:34913 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756576AbcKKPe2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 10:34:28 -0500
Received: by mail-wm0-f44.google.com with SMTP id a197so431741968wmd.0
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 07:34:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Please, queue-up both for stable. Thanks!

---
v1->v2:
- patch 1:
 - fix this rather by initializing refcount to 1
 - fix typo in description
- patch 2:
 - remove an extra space
 - fix the description

Arkadi Sharshevsky (1):
  mlxsw: spectrum_router: Correctly dump neighbour activity

Yotam Gigi (1):
  mlxsw: spectrum: Fix refcount bug on span entries

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  4 +++-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 22 +++++++++++++++++++++-
 2 files changed, 24 insertions(+), 2 deletions(-)

-- 
2.7.4
