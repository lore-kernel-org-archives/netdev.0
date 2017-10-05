From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/2] mlxsw: Add more extack error reporting
Date: Thu,  5 Oct 2017 23:39:58 +0200
Message-ID: <20171005214000.14022-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:51050 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751369AbdJEVkC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 17:40:02 -0400
Received: by mail-wm0-f66.google.com with SMTP id u138so4370152wmu.5
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 14:40:01 -0700 (PDT)
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
