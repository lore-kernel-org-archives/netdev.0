From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] mlxsw: Fixes in GRE offloading
Date: Mon,  2 Oct 2017 12:14:55 +0200
Message-ID: <20171002101457.1462-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:38896 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750949AbdJBKO7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 06:14:59 -0400
Received: by mail-wr0-f195.google.com with SMTP id 45so3470343wry.5
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 03:14:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Petr says:

This patchset fixes a couple unrelated problems in offloading IP-in-IP tunnels
in mlxsw driver.

- The first patch fixes a potential reference-counting problem that might lead
  to a kernel crash.

- The second patch associates IPIP next hops with their loopback RIFs. Besides
  being the right thing to do, it also fixes a problem where offloaded IPv6
  routes that forward to IP-in-IP netdevices were not flagged as such.

Petr Machata (2):
  mlxsw: spectrum_router: Move VRF refcounting
  mlxsw: spectrum_router: Track RIF of IPIP next hops

 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

-- 
2.9.5
