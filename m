From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/3] mlxsw: Couple of fixes
Date: Fri,  6 May 2016 11:17:21 +0200
Message-ID: <1462526244-11898-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36152 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbcEFJR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 05:17:27 -0400
Received: by mail-wm0-f54.google.com with SMTP id n129so50122556wmn.1
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 02:17:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido Schimmel (2):
  mlxsw: spectrum: Fix rollback order in LAG join failure
  mlxsw: spectrum: Add missing rollback in flood configuration

Jiri Pirko (1):
  mlxsw: spectrum: Fix ordering in mlxsw_sp_fini

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c           | 5 +++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 8 ++++++++
 2 files changed, 11 insertions(+), 2 deletions(-)

-- 
2.5.5
