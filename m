From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net v2 0/2] mlxsw: Couple of router fixes
Date: Thu, 10 Nov 2016 12:31:03 +0100
Message-ID: <1478777465-6567-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33523 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754684AbcKJLbI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 06:31:08 -0500
Received: by mail-wm0-f66.google.com with SMTP id u144so2513730wmu.0
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 03:31:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

---
v1->v2:
- patch2:
 - use net_eq

Jiri Pirko (2):
  mlxsw: spectrum_router: Fix handling of neighbour structure
  mlxsw: spectrum_router: Ignore FIB notification events for non-init
    namespaces

 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 98 ++++++++--------------
 1 file changed, 37 insertions(+), 61 deletions(-)

-- 
2.7.4
