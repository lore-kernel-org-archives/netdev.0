From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/3] mlxsw: Remove compatibility with old firmware
Date: Thu,  8 Jun 2017 08:47:42 +0200
Message-ID: <20170608064745.4900-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33279 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751299AbdFHGrs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 02:47:48 -0400
Received: by mail-wm0-f65.google.com with SMTP id x3so5682963wme.0
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 23:47:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Up until recently we couldn't enforce a minimal firmware version, which
forced us to be compatible with old firmware versions. This patchset
removes this code and simplifies the driver.

Ido Schimmel (3):
  mlxsw: spectrum_router: Mark only first LPM tree as reserved
  mlxsw: spectrum: Simplify port split flow
  mlxsw: spectrum: Pass port argument to module mapping functions

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 114 ++++++---------------
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |   2 +-
 2 files changed, 35 insertions(+), 81 deletions(-)

-- 
2.9.3
