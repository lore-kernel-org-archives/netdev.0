From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 3/7] net: mvneta: Use cacheable memory to
 store the rx buffer virtual address
Date: Wed, 30 Nov 2016 13:57:25 -0500 (EST)
Message-ID: <20161130.135725.407314756675613303.davem@davemloft.net>
References: <cover.654978388d6811b943dd58ecb9a9d9b6cceeaee3.1480431285.git-series.gregory.clement@free-electrons.com>
        <cover.654978388d6811b943dd58ecb9a9d9b6cceeaee3.1480431285.git-series.gregory.clement@free-electrons.com>
        <bb2f1a61e9b912905f8390f7a06c36f9f1e7ab66.1480431285.git-series.gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        jszhang@marvell.com, arnd@arndb.de, jason@lakedaemon.net,
        andrew@lunn.ch, sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com,
        linux-arm-kernel@lists.infradead.org, nadavh@marvell.com,
        mw@semihalf.com, dima@marvell.com, yelena@marvell.com
To: gregory.clement@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39454 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933106AbcK3S52 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 13:57:28 -0500
In-Reply-To: <bb2f1a61e9b912905f8390f7a06c36f9f1e7ab66.1480431285.git-series.gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Date: Tue, 29 Nov 2016 15:55:21 +0100

> +	/* Virtual address of the RX buffer */
> +	void  **buf_virt_addr;
> +
>  	/* Virtual address of the RX DMA descriptors array */
>  	struct mvneta_rx_desc *descs;
>  
 ...
> +		data = (unsigned char *)rxq->buf_virt_addr[index];

This cast is unnecessary, please remove it.
