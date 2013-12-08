From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next 07/12] net/mlx4_en: Configure the XPS queue mapping
 on driver load
Date: Sun, 8 Dec 2013 17:42:39 +0200
Message-ID: <52A4936F.3040004@mellanox.com>
References: <1386506152-10298-1-git-send-email-amirv@mellanox.com> <1386506152-10298-8-git-send-email-amirv@mellanox.com> <52A4901E.2030906@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	<netdev@vger.kernel.org>, Ido Shamay <idos@mellanox.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:45599 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755000Ab3LHPmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 10:42:45 -0500
In-Reply-To: <52A4901E.2030906@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/12/2013 17:28, Sergei Shtylyov wrote:
> Hello.
> 
> On 08-12-2013 16:35, Amir Vadai wrote:
> 
>> From: Ido Shamay <idos@mellanox.com>
> 
>> Only TX rings of User Piority 0 are mapped.
>> TX rings of other UP's are using UP 0 mapping.
>> XPS is not in use when num_tc is set.
> 
>> Signed-off-by: Ido Shamay <idos@mellanox.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> [...]
> 
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
>> b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
>> index fa33a83..a4cdd7d 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
>> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> [...]
>> @@ -708,8 +710,9 @@ u16 mlx4_en_select_queue(struct net_device *dev,
>> struct sk_buff *skb);
>>   netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev);
>>
>>   int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
>> -               struct mlx4_en_tx_ring **pring,
>> -               int qpn, u32 size, u16 stride, int node);
>> +            struct mlx4_en_tx_ring **pring,
>> +            int qpn, u32 size, u16 stride,
>> +            int node, int queue_index);
> 
>    Why you've changed the indentation here -- it was alright before.
Right - changed by mistake. Will be fixed in V1.

> 
>>   void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
>>                    struct mlx4_en_tx_ring **pring);
>>   int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
> 
> WBR, Sergei
> 

Amir
