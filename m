From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next repost 0/2] mlxsw: Add more extack error reporting
Date: Sun,  8 Oct 2017 11:57:54 +0200
Message-ID: <20171008095756.2139-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36393 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751463AbdJHJ56 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2017 05:57:58 -0400
Received: by mail-wm0-f68.google.com with SMTP id 131so10336462wmk.3
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 02:57:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

Add error messages to VLAN and bridge enslavements to help users
understand why the enslavement failed.

Ido Schimmel (2):
  mlxsw: spectrum: Add extack for VLAN enslavements
  mlxsw: spectrum: Propagate extack further for bridge enslavements

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 18 ++++++++++++----
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  3 ++-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 25 +++++++++++++++-------
 3 files changed, 33 insertions(+), 13 deletions(-)

-- 
2.9.5
