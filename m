From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] mlxsw: couple of fixes
Date: Thu,  9 Jun 2016 09:51:38 +0200
Message-ID: <1465458700-5744-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:38157 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753930AbcFIHvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 03:51:44 -0400
Received: by mail-wm0-f43.google.com with SMTP id m124so47836130wme.1
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 00:51:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Couple of fixes from Ido.

Ido Schimmel (2):
  mlxsw: spectrum: Make split flow match firmware requirements
  mlxsw: spectrum: Don't sleep during ndo_get_phys_port_name()

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 203 ++++++++++++++-----------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |   5 +
 2 files changed, 117 insertions(+), 91 deletions(-)

-- 
2.5.5
