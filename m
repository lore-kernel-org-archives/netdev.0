From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/2] mlxsw: Add per-{Prio,TC} counters
Date: Tue, 19 Jul 2016 15:35:52 +0200
Message-ID: <1468935354-7008-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35739 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753508AbcGSNf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 09:35:57 -0400
Received: by mail-wm0-f54.google.com with SMTP id f65so139216257wmi.0
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 06:35:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

Add per-priority and per-tc counters, which are very useful for debugging
purposes and fine-tuning.

Ido Schimmel (2):
  mlxsw: spectrum: Expose per-priority counters via ethtool
  mlxsw: spectrum: Expose per-tc counters via ethtool

 drivers/net/ethernet/mellanox/mlxsw/reg.h      |  18 +++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 162 +++++++++++++++++++++++--
 2 files changed, 171 insertions(+), 9 deletions(-)

-- 
2.5.5
