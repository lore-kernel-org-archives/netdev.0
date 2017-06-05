From: Jes Sorensen <jes.sorensen@gmail.com>
Subject: [PATCH 0/1] Allow TC support to be disabled
Date: Mon,  5 Jun 2017 16:53:57 -0400
Message-ID: <20170605205358.20211-1-jsorensen@fb.com>
Cc: kernel-team@fb.com, saeedm@mellanox.com, ilant@mellanox.com,
        Jes Sorensen <jsorensen@fb.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f169.google.com ([209.85.213.169]:32913 "EHLO
        mail-yb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751180AbdFEUyI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 16:54:08 -0400
Received: by mail-yb0-f169.google.com with SMTP id 202so36528091ybd.0
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 13:54:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Here is the follow-on patch which allows for TC support to be compiled
out.

It builds on top of my patch set from last week.

Jes


Jes Sorensen (1):
  mlx5: Allow TC support to be disabled in the build

 drivers/net/ethernet/mellanox/mlx5/core/Kconfig   | 10 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/Makefile  |  4 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 39 ++++++-----------------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  | 12 +++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   | 29 +++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h   |  1 +
 6 files changed, 65 insertions(+), 30 deletions(-)

-- 
2.13.0
