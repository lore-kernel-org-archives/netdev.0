From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net] net/mlx4: Fix the check in attaching steering rules
Date: Tue, 23 May 2017 16:46:03 +0300
Message-ID: <06fc16e1-7ff0-3ab2-4160-1c26a72cf0fa@mellanox.com>
References: <1495543807-14956-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Eran Ben Elisha <eranbe@mellanox.com>,
        Talat Batheesh <talatb@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0065.outbound.protection.outlook.com ([104.47.0.65]:5609
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1761866AbdEWNqK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 09:46:10 -0400
In-Reply-To: <1495543807-14956-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/23/2017 3:50 PM, Tariq Toukan wrote:
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
> Reported-by: Or Gerlitz <gerlitz.or@gmail.com>
> Signed-off-by: Talat Batheesh <talatb@mellanox.com>
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>

Acked-by: Or Gerlitz <ogerlitz@mellanox.com>
