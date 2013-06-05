From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4: use __netdev_pick_tx instead of
 __skb_tx_hash in mlx4_en_select_queue
Date: Tue, 04 Jun 2013 17:30:12 -0700 (PDT)
Message-ID: <20130604.173012.779221049139005207.davem@davemloft.net>
References: <1370282862-13302-1-git-send-email-govindarajulu90@gmail.com>
	<51ADC6DE.7060004@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: govindarajulu90@gmail.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60658 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520Ab3FEAaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 20:30:13 -0400
In-Reply-To: <51ADC6DE.7060004@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Tue, 4 Jun 2013 13:52:14 +0300

> On 03/06/2013 21:07, govindarajulu.v wrote:
>> From: "govindarajulu.v" <govindarajulu90@gmail.com>
>> 
>> mlx4_en_select_queue() uses __skb_tx_hash to select the transmit queue.
>> XPS settings are ignored by this. Instead, we can use __netdev_pick_tx
>> to select the transmit queue.
>> 
>> Compile test only.
>> 
>> Signed-off-by: govindarajulu.v <govindarajulu90@gmail.com>
 ...
> Acked-By: Amir Vadai <amirv@mellanox.com>

Applied, thanks.
