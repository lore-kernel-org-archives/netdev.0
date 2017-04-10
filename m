From: idosch@idosch.org
Subject: [PATCH net v3 0/2] bridge: Fix kernel oops during bridge creation
Date: Mon, 10 Apr 2017 14:59:26 +0300
Message-ID: <20170410115928.9344-1-idosch@idosch.org>
Cc: davem@davemloft.net, stephen@networkplumber.org,
        bridge@lists.linux-foundation.org, mlxsw@mellanox.com,
        peter@svinota.eu, nikolay@cumulusnetworks.com,
        Ido Schimmel <idosch@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:57884 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752955AbdDJMAl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 08:00:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

First patch adds a missing ndo_uninit() in the bridge driver, which is a
prerequisite for the second patch that actually fixes the oops.

Please consider both patches for 4.4.y, 4.9.y and 4.10.y

Ido Schimmel (2):
  bridge: implement missing ndo_uninit()
  bridge: netlink: register netdevice before executing changelink

 net/bridge/br_device.c    | 20 +++++++++++---------
 net/bridge/br_if.c        |  1 -
 net/bridge/br_multicast.c |  7 +++++--
 net/bridge/br_netlink.c   |  7 +++++--
 net/bridge/br_private.h   |  5 +++++
 5 files changed, 26 insertions(+), 14 deletions(-)

-- 
2.9.3
