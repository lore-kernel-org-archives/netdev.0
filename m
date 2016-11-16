From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net/mlx5e: remove napi_hash_del() calls
Date: Wed, 16 Nov 2016 05:55:37 -0800
Message-ID: <1479304537.8455.167.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34587 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751953AbcKPNzj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 08:55:39 -0500
Received: by mail-pg0-f68.google.com with SMTP id e9so14442769pgc.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 05:55:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Calling napi_hash_del() after netif_napi_del() is pointless.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    4 ----
 1 file changed, 4 deletions(-)
