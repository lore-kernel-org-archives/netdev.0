From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_en: Fix user prio field in XDP forward
Date: Thu, 22 Dec 2016 11:21:09 -0500 (EST)
Message-ID: <20161222.112109.1358243840382527116.davem@davemloft.net>
References: <1482409978-17590-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, saeedm@mellanox.com,
        kafai@fb.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46730 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965524AbcLVQVL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 11:21:11 -0500
In-Reply-To: <1482409978-17590-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Thu, 22 Dec 2016 14:32:58 +0200

> The user prio field is wrong (and overflows) in the XDP forward
> flow.
> This is a result of a bad value for num_tx_rings_p_up, which should
> account all XDP TX rings, as they operate for the same user prio.
> 
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> Reported-by: Martin KaFai Lau <kafai@fb.com>

Applied.
