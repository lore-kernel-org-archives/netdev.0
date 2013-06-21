From: Amir Vadai <amirv.mellanox@gmail.com>
Subject: Re: [PATCH net-next 07/11] net/mlx4_en: Add prints when TX timeout
 occurs
Date: Fri, 21 Jun 2013 08:31:49 +0300
Message-ID: <51C3E545.3020003@gmail.com>
References: <1371757222-21412-1-git-send-email-amirv@mellanox.com>  <1371757222-21412-8-git-send-email-amirv@mellanox.com> <1371758105.2146.39.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:65385 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935551Ab3FUFbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 01:31:53 -0400
Received: by mail-we0-f174.google.com with SMTP id q58so5951341wes.5
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 22:31:52 -0700 (PDT)
In-Reply-To: <1371758105.2146.39.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/06/2013 22:55, Joe Perches wrote:
> On Thu, 2013-06-20 at 22:40 +0300, Amir Vadai wrote:
>> From: Yevgeny Petrilin <yevgenyp@mellanox.com>
>>
>> Debug prints when a TX timeout is detected
> []
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> []
>> @@ -1236,10 +1236,21 @@ static void mlx4_en_tx_timeout(struct net_device *dev)
> []
>> +	for (i = 0; i < priv->tx_ring_num; i++) {
>> +		if (!netif_tx_queue_stopped(netdev_get_tx_queue(dev, i)))
>> +			continue;
>> +		en_info(priv, "TX timeout detected on queue: %d,\n"
>> +			"QP: 0x%x, CQ: 0x%x,\n"
>> +			"Cons index: 0x%x, Prod index: 0x%x\n", i,
> 
> Not at dbg level and probably better on a single line.
> 

Will be fixed in v1
