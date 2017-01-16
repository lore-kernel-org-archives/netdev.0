From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Disallow duplicate
 internal elements
Date: Mon, 16 Jan 2017 15:06:07 -0500 (EST)
Message-ID: <20170116.150607.163117421916166968.davem@davemloft.net>
References: <1484556313-33614-1-git-send-email-paulb@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, roid@mellanox.com,
        ogerlitz@mellanox.com, hadarh@mellanox.com
To: paulb@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47850 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750834AbdAPUGJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 15:06:09 -0500
In-Reply-To: <1484556313-33614-1-git-send-email-paulb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Blakey <paulb@mellanox.com>
Date: Mon, 16 Jan 2017 10:45:13 +0200

> Flower currently allows having the same filter twice with the same
> priority. Actions (and statistics update) will always execute on the
> first inserted rule leaving the second rule unused.
> This patch disallows that.
> 
> Signed-off-by: Paul Blakey <paulb@mellanox.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks.
