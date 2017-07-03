From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlxfw: Properly handle dependancy with
 non-loadable mlx5
Date: Mon, 03 Jul 2017 02:32:38 -0700 (PDT)
Message-ID: <20170703.023238.1801330975202162070.davem@davemloft.net>
References: <1499011048-24941-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, saeedm@mellanox.com, mlxsw@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54908 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753602AbdGCJcm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 05:32:42 -0400
In-Reply-To: <1499011048-24941-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun,  2 Jul 2017 18:57:28 +0300

> If mlx5 is set to be built-in and mlxfw as a module, we
> get a link error:
> 
> drivers/built-in.o: In function `mlx5_firmware_flash':
> (.text+0x5aed72): undefined reference to `mlxfw_firmware_flash'
> 
> Since we don't want to mandate selecting mlxfw for mlx5 users, we
> use the IS_REACHABLE macro to make sure that a stub is exposed
> to the caller.
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Reported-by: Jakub Kicinski <kubakici@wp.pl>
> Reported-by: Arnd Bergmann <arnd@arndb.de>

Applied, thank you.
