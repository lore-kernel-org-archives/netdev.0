From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V1 2/2] net/mlx4_en: Add netdev support for TCP/IP
 offloads of vxlan tunneling
Date: Sun, 22 Dec 2013 16:53:43 +0200
Message-ID: <52B6FCF7.5010205@mellanox.com>
References: <1387720854-1355-1-git-send-email-ogerlitz@mellanox.com>	 <1387720854-1355-3-git-send-email-ogerlitz@mellanox.com> <1387721989.22671.16.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<amirv@mellanox.com>, <yanb@mellanox.com>, <ast@plumgrid.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:52499 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753296Ab3LVPDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 10:03:14 -0500
In-Reply-To: <1387721989.22671.16.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/12/2013 16:19, Joe Perches wrote:
>> >+	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
>> >+		dev->hw_enc_features = NETIF_F_SG | NETIF_F_IP_CSUM |
>> >+					NETIF_F_RXCSUM | NETIF_F_TSO |
>> >+					NETIF_F_GSO_UDP_TUNNEL;
>> >+		dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
>> >+		dev->features    |= NETIF_F_GSO_UDP_TUNNEL;
> Perhaps hw_enc_features should be |= as well.
> NETIF_F_SG is set in register_netdevice() for hw_enc_features.
>

OK, I'll do that, thanks for spotting this over.
