From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V4] net/mlx4: Fix the check in attaching steering
 rules
Date: Sun, 04 Jun 2017 23:14:06 -0400 (EDT)
Message-ID: <20170604.231406.1093500953540605870.davem@davemloft.net>
References: <1496575807-27979-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, ogerlitz@mellanox.com,
        talatb@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55416 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751208AbdFEDOZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 23:14:25 -0400
In-Reply-To: <1496575807-27979-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Sun,  4 Jun 2017 14:30:07 +0300

> From: Talat Batheesh <talatb@mellanox.com>
> 
> Our previous patch (cited below) introduced a regression
> for RAW Eth QPs.
> 
> Fix it by checking if the QP number provided by user-space
> exists, hence allowing steering rules to be added for valid
> QPs only.
> 
> Fixes: 89c557687a32 ("net/mlx4_en: Avoid adding steering rules with invalid ring")
> Reported-by: Or Gerlitz <gerlitz.or@gmail.com>
> Signed-off-by: Talat Batheesh <talatb@mellanox.com>
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> Acked-by: Or Gerlitz <ogerlitz@mellanox.com>
> Reviewed-by: Leon Romanovsky <leonro@mellanox.com>

Applied, thanks.
