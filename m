From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH v4 net-next 3/7] net: mvneta: Use cacheable memory to store the rx buffer virtual address
Date: Wed, 30 Nov 2016 22:27:47 +0100
Message-ID: <87k2bklkto.fsf@free-electrons.com>
References: <cover.654978388d6811b943dd58ecb9a9d9b6cceeaee3.1480431285.git-series.gregory.clement@free-electrons.com>
        <cover.654978388d6811b943dd58ecb9a9d9b6cceeaee3.1480431285.git-series.gregory.clement@free-electrons.com>
        <bb2f1a61e9b912905f8390f7a06c36f9f1e7ab66.1480431285.git-series.gregory.clement@free-electrons.com>
        <20161130.135725.407314756675613303.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        jszhang@marvell.com, arnd@arndb.de, jason@lakedaemon.net,
        andrew@lunn.ch, sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com,
        linux-arm-kernel@lists.infradead.org, nadavh@marvell.com,
        mw@semihalf.com, dima@marvell.com, yelena@marvell.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161130.135725.407314756675613303.davem@davemloft.net> (David
        Miller's message of "Wed, 30 Nov 2016 13:57:25 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,
 
 On mer., nov. 30 2016, David Miller <davem@davemloft.net> wrote:

> From: Gregory CLEMENT <gregory.clement@free-electrons.com>
> Date: Tue, 29 Nov 2016 15:55:21 +0100
>
>> +	/* Virtual address of the RX buffer */
>> +	void  **buf_virt_addr;
>> +
>>  	/* Virtual address of the RX DMA descriptors array */
>>  	struct mvneta_rx_desc *descs;
>>  
>  ...
>> +		data = (unsigned char *)rxq->buf_virt_addr[index];
>
> This cast is unnecessary, please remove it.

OK I am doing it now.

Thanks,

Gregory


-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
