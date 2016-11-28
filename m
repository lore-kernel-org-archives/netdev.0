From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/4] mlxsw: couple of enhancements and fixes
Date: Mon, 28 Nov 2016 18:01:22 +0100
Message-ID: <1480352486-18518-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36143 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933526AbcK1RCI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:02:08 -0500
Received: by mail-wm0-f65.google.com with SMTP id m203so20024149wma.3
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 09:02:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Couple of enhancements and fixes from Ido.

Ido Schimmel (4):
  mlxsw: resources: Add maximum buffer size
  mlxsw: spectrum_buffers: Limit size of pools
  mlxsw: core: Add missing rollback in error path
  mlxsw: core: Change order of operations in removal path

 drivers/net/ethernet/mellanox/mlxsw/core.c             | 3 ++-
 drivers/net/ethernet/mellanox/mlxsw/resources.h        | 2 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 3 +++
 3 files changed, 7 insertions(+), 1 deletion(-)

-- 
2.7.4
