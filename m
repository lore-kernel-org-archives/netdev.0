From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V3] net/mlx4: Fix the check in attaching steering
 rules
Date: Thu, 01 Jun 2017 11:56:33 -0400 (EDT)
Message-ID: <20170601.115633.38542061957246611.davem@davemloft.net>
References: <1496308606-13653-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, ogerlitz@mellanox.com,
        talatb@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56382 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751705AbdFAP4f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 11:56:35 -0400
In-Reply-To: <1496308606-13653-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Thu,  1 Jun 2017 12:16:46 +0300

> From: Talat Batheesh <talatb@mellanox.com>
> 
> Our previous patch (cited below) introduced a regression
> for RAW Eth QPs.
> 
> Fix it by checking if the QP number provided by user-space
> exists, hence allowing steering rules to be added for valid
> QPs only.
> 
> Fixes: 89c557687a32 ("net/mlx4_en: Avoid adding steering rules with ...")

Please do not truncate the commit header line text, always provide the
whole thing and do not break up the Fixes: line with newlines even if
the line exceeds 80 columns so people can grep it into the logs.

Thank you.
