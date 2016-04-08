From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/5] mlxsw: small driver update
Date: Fri,  8 Apr 2016 17:45:20 +0200
Message-ID: <1460130325-14931-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36454 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754361AbcDHPpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 11:45:30 -0400
Received: by mail-wm0-f67.google.com with SMTP id l6so5272359wml.3
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 08:45:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Cosmetics, in preparation to sharedbuffer patchset.

Jiri Pirko (5):
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
 7 files changed, 114 insertions(+), 112 deletions(-)

-- 
2.5.5
