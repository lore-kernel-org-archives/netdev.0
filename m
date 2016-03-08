From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 0/3] bridge: ageing timer regression fix
Date: Tue,  8 Mar 2016 12:59:32 -0800
Message-ID: <1457470775-32224-1-git-send-email-stephen@networkplumber.org>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36259 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649AbcCHU7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 15:59:23 -0500
Received: by mail-pf0-f174.google.com with SMTP id 63so21155051pfe.3
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 12:59:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes regression in how ageing timer is managed.
Backing out the change required fixing switch drivers as well.

Ido Schimmel (2):
  mlxsw: spectrum: Check requested ageing time is valid
  rocker: Set FDB cleanup timer according to lowest ageing time

Stephen Hemminger (1):
  bridge: fix regression in ageing time

 drivers/net/ethernet/mellanox/mlxsw/spectrum.h           |  2 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c |  9 +++++++--
 drivers/net/ethernet/rocker/rocker.c                     |  8 +++++++-
 include/linux/if_bridge.h                                |  4 ----
 net/bridge/br_stp.c                                      | 11 ++++++++---
 5 files changed, 24 insertions(+), 10 deletions(-)

-- 
2.1.4
