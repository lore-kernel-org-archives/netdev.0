From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] mlxsw: Couple of fixes
Date: Fri,  6 May 2016 22:18:38 +0200
Message-ID: <1462565920-1959-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35215 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758541AbcEFUSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 16:18:43 -0400
Received: by mail-wm0-f42.google.com with SMTP id e201so70359737wme.0
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 13:18:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido Schimmel (2):
  mlxsw: spectrum: Fix rollback order in LAG join failure
  mlxsw: spectrum: Add missing rollback in flood configuration

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c           | 4 ++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 8 ++++++++
 2 files changed, 10 insertions(+), 2 deletions(-)

-- 
2.5.5
