From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] net: ppv2: various improvements
Date: Wed, 01 Nov 2017 12:29:27 +0900 (KST)
Message-ID: <20171101.122927.995387506631986251.davem@davemloft.net>
References: <20171030102333.30781-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: antoine.tenart@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171030102333.30781-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Mon, 30 Oct 2017 11:23:27 +0100

> This series includes various patches improving the Marvell PPv2 driver.
> I send them as a series to avoid any possible merge conflict.
> 
> - Patches 1 and 2 improve the initializing of the Tx and Rx FIFO.
> - Patch 3 initialize the RSS table to evenly distribute the ingress
>   packets across multiple Rx queues based on their hashes.
> - Patch 4 limits the number of TSO segments sent to the driver, to avoid
>   having more segments to handle than the corresponding number of
>   available descriptors.
> - Patch 5 and 6 are cosmetic improvements.
> 
> This applies on today's net-next branch, The patches were tested
> extensively (I ran iperf and http downloads in parallel, transferring
> TBs of data).

Series applied, thanks.
