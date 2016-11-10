From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] mlxsw: Couple of router fixes
Date: Thu, 10 Nov 2016 12:00:47 +0100
Message-ID: <1478775649-3386-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36625 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754542AbcKJLAw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 06:00:52 -0500
Received: by mail-wm0-f54.google.com with SMTP id g23so33367147wme.1
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 03:00:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Jiri Pirko (2):
  mlxsw: spectrum_router: Fix handling of neighbour structure
  mlxsw: spectrum_router: Ignore FIB notification events for non-init
    namespaces

 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 98 ++++++++--------------
 1 file changed, 37 insertions(+), 61 deletions(-)

-- 
2.7.4
