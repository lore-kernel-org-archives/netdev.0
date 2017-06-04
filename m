From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/3] mlxsw: Minor cleanup
Date: Sun,  4 Jun 2017 16:53:37 +0200
Message-ID: <20170604145340.14447-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, petrm@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34897 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751159AbdFDOxn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 10:53:43 -0400
Received: by mail-wm0-f65.google.com with SMTP id g15so26075631wmc.2
        for <netdev@vger.kernel.org>; Sun, 04 Jun 2017 07:53:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Fix small issues I noticed during the refactoring.

First patch adds file name comments in the header file to make it clear
what goes where. Second patch fixes a typo and third patch simply aligns
RIF index allocation with similar allocations in the driver.

Ido Schimmel (3):
  mlxsw: spectrum: Tidy up header file
  mlxsw: Fix typo inside enumeration
  mlxsw: spectrum_router: Align RIF index allocation with existing code

 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     | 47 ++++++++++++----------
 drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c |  6 +--
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 24 +++++------
 4 files changed, 41 insertions(+), 38 deletions(-)

-- 
2.9.3
