From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 00/13] mvneta Buffer Management and enhancements
Date: Sun, 22 Nov 2015 21:06:34 +0100
Message-ID: <12984648.7CKVgBs7pu@wuerfel>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Marcin Wojtas <mw@semihalf.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	andrew@lunn.ch, linux@arm.linux.org.uk, jason@lakedaemon.net,
	myair@marvell.com, jaz@semihalf.com, simon.guinot@sequanux.org,
	xswang@marvell.com, nadavh@marvell.com, alior@marvell.com,
	tn@semihalf.com, gregory.clement@free-electrons.com,
	nitroshift@yahoo.com, davem@davemloft.net,
	sebastian.hesselbarth@gmail.com
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448178839-3541-1-git-send-email-mw@semihalf.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 22 November 2015 08:53:46 Marcin Wojtas wrote:
> 
> 3. Optimisations - concatenating TX descriptors' flush, basing on
> xmit_more support and combined approach for finalizing egress processing.
> Thanks to HR timer buffers can be released with small latency, which is
> good for low transfer and small queues. Along with the timer, coalescing
> irqs are used, whose threshold could be increased back to 15.
> 
> 

If you are already reworking the TX path, it probably makes sense to 
support BQL as well, see the Marvell skge and sky2 drivers for examples
using netdev_{tx_,}{sent,completed}_queue.

	Arnd
