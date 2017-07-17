From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/6] mlxsw: offloading matches on ip ttl and tos
Date: Mon, 17 Jul 2017 14:07:25 +0200
Message-ID: <20170717120731.3875-1-jiri@resnulli.us>
Cc: davem@davemloft.net, ogerlitz@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33320 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751280AbdGQMHf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 08:07:35 -0400
Received: by mail-wr0-f194.google.com with SMTP id 40so2492041wrw.0
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 05:07:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Or says:

Support offloading matches on ip ttl and tos

Or Gerlitz (6):
  mlxsw: acl: Add ip ttl acl element
  mlxsw: spectrum: Add ttl to the ipv4 acl block
  mlxsw: spectrum_flower: Add support for ip ttl
  mlxsw: acl: Add ip tos acl element
  mlxsw: spectrum: Add tos to the ipv4 acl block
  mlxsw: spectrum_flower: Add support for ip tos

 .../ethernet/mellanox/mlxsw/core_acl_flex_keys.h   |  6 +++
 .../mellanox/mlxsw/spectrum_acl_flex_keys.h        |  3 ++
 .../ethernet/mellanox/mlxsw/spectrum_acl_tcam.c    |  3 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  | 44 +++++++++++++++++++++-
 4 files changed, 54 insertions(+), 2 deletions(-)

-- 
2.9.3
