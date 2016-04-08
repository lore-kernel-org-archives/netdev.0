From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/6] mlxsw: small driver update + one tiny devlink dependency
Date: Fri,  8 Apr 2016 19:11:19 +0200
Message-ID: <1460135485-16095-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34124 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332AbcDHRL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 13:11:28 -0400
Received: by mail-wm0-f68.google.com with SMTP id n3so5826836wmn.1
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 10:11:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Cosmetics, in preparation to sharedbuffer patchset.
First patch is here to allow patch number two.

Jiri Pirko (6):
  devlink: remove implicit type set in port register
  mlxsw: Move devlink port registration into common core code
  mlxsw: Pass mlxsw_core as a param of mlxsw_core_skb_transmit*
  mlxsw: Do not pass around driver_priv directly
  mlxsw: reg: Share direction enum between SBPR, SBCM, SBPM
  mlxsw: reg: Fix SBPM register name

 drivers/net/ethernet/mellanox/mlxsw/core.c         | 56 ++++++++++++++--------
 drivers/net/ethernet/mellanox/mlxsw/core.h         | 26 +++++++---
 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 27 ++++-------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 52 +++++++++-----------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  3 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 20 ++++----
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c     | 42 +++++++---------
 net/core/devlink.c                                 |  1 -
 8 files changed, 114 insertions(+), 113 deletions(-)

-- 
2.5.5
