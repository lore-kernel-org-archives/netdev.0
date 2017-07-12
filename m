From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/4] mlxsw: spectrum: Various fixes
Date: Wed, 12 Jul 2017 09:12:51 +0200
Message-ID: <20170712071255.1232-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35372 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751378AbdGLHM7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 03:12:59 -0400
Received: by mail-wr0-f193.google.com with SMTP id z45so3657329wrb.2
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2017 00:12:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

First patch adds a missing rollback in error path. Second patch prevents
a use-after-free during IPv4 route replace. Last two patches fix warnings
from static checkers.

Ido Schimmel (4):
  mlxsw: spectrum_router: Add missing rollback
  mlxsw: spectrum_router: Fix use-after-free in route replace
  mlxsw: spectrum_switchdev: Remove unused variable
  mlxsw: spectrum_switchdev: Check status of memory allocation

 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c    | 4 ++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 9 ++++++---
 2 files changed, 10 insertions(+), 3 deletions(-)

-- 
2.9.3
