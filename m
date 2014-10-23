From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH for-net 0/2] irq sync fixes
Date: Thu, 23 Oct 2014 15:57:25 +0300
Message-ID: <1414069047-30865-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:62744 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755741AbaJWM5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 08:57:33 -0400
Received: by mail-wi0-f171.google.com with SMTP id em10so4034683wid.10
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 05:57:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This two patch series fixes a race where an interrupt handler could access a
freed memory.

Eli

Eli Cohen (2):
  net/mlx5_core: Call synchronize_irq() before freeing EQ buffer
  net/mlx4_core: Call synchronize_irq() before freeing EQ buffer

 drivers/net/ethernet/mellanox/mlx4/eq.c      | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/eq.c | 1 +
 2 files changed, 2 insertions(+)

-- 
2.1.2
