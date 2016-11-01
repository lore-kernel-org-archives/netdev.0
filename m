From: Saeed Mahameed <saeedm@mellanox.com>
Subject: Re: [PATCH net-next V2 3/3] net/mlx4_en: Add ethtool statistics for
 XDP cases
Date: Tue, 1 Nov 2016 13:57:58 +0200
Message-ID: <fac4eb19-e2e4-4346-f5b0-a49caa6989ea@mellanox.com>
References: <1478000186-5158-1-git-send-email-tariqt@mellanox.com>
 <1478000186-5158-4-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Eran Ben Elisha <eranbe@mellanox.com>,
        "Brenden Blanco" <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0050.outbound.protection.outlook.com ([104.47.2.50]:2209
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751316AbcKAQ3w (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 12:29:52 -0400
In-Reply-To: <1478000186-5158-4-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11/01/2016 01:36 PM, Tariq Toukan wrote:
> XDP statistics are reported in ethtool as follows:
> - xdp_drop: the number of packets dropped by xdp.
> - xdp_tx: the number of packets forwarded by xdp.
> - xdp_tx_full: the number of times an xdp forward failed
> 	due to a full tx xdp ring.
>
> In addition, all packets that are dropped/forwarded by XDP
> are no longer accounted in rx_packets/rx_bytes of the ring,
> so that they count traffic that is passed to the stack.
>
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>

Reviewed-by: Saeed Mahameed <saeedm@mellanox.com>
