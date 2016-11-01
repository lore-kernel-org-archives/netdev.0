From: Saeed Mahameed <saeedm@mellanox.com>
Subject: Re: [PATCH net-next V2 2/3] net/mlx4_en: Refactor the XDP forwarding
 rings scheme
Date: Tue, 1 Nov 2016 13:57:36 +0200
Message-ID: <a582496e-f8ec-a3b0-e81a-b70b8df89237@mellanox.com>
References: <1478000186-5158-1-git-send-email-tariqt@mellanox.com>
 <1478000186-5158-3-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Eran Ben Elisha <eranbe@mellanox.com>,
        "Brenden Blanco" <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0062.outbound.protection.outlook.com ([104.47.2.62]:2912
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1424375AbcKAObu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 10:31:50 -0400
In-Reply-To: <1478000186-5158-3-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11/01/2016 01:36 PM, Tariq Toukan wrote:
> Separately manage the two types of TX rings: regular ones, and XDP.
> Upon an XDP set, do not borrow regular TX rings and convert them
> into XDP ones, but allocate new ones, unless we hit the max number
> of rings.
> Which means that in systems with smaller #cores we will not consume
> the current TX rings for XDP, while we are still in the num TX limit.
>
> XDP TX rings counters are not shown in ethtool statistics.
> Instead, XDP counters will be added to the respective RX rings
> in a downstream patch.
>
> This has no performance implications.
>
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>

Reviewed-by: Saeed Mahameed <saeedm@mellanox.com>
