From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] mlxsw: couple of fixes
Date: Fri, 17 Jun 2016 15:09:04 +0200
Message-ID: <1466168946-14658-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:33922 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932553AbcFQNJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 09:09:10 -0400
Received: by mail-wm0-f53.google.com with SMTP id k184so37653330wme.1
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 06:09:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Couple of slowpath tx stats fixes for Spectrum and SwitchX-2.

Nogah Frankel (2):
  mlxsw: spectrum: Don't count internal TX header bytes to stats
  mlxsw: switchx2: Don't count internal TX header bytes to stats

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 6 +++++-
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 5 ++++-
 2 files changed, 9 insertions(+), 2 deletions(-)

-- 
2.5.5
