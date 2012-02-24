From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: RE: [PATCH net-next 1/3] mlx4_en: TX ring size default to 1024
Date: Fri, 24 Feb 2012 19:35:45 +0000
Message-ID: <953B660C027164448AE903364AC447D2618B8768@MTLDAG02.mtl.com>
References: <4F46404D.10509@mellanox.co.il>
 <20120223.144541.1354349294973443529.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:38233 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754408Ab2BXTfv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 14:35:51 -0500
In-Reply-To: <20120223.144541.1354349294973443529.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> 
> This is rediculious as a default, yes even for 10Gb.
> 
> Do you have any idea how high latency is going to be for packets
> trying to get into the transmit queue if there are already a
> thousand other frames in there?

On the other hand, when having smaller queue with 1000 in-flight packets would mean queue would be stopped,
how is it better?
Having bigger TX ring helps dealing better with bursts of TX packets, without the overhead of stopping and starting the queue,
It also makes sense to have same size TX and RX queues, for example in case of traffic being forwarded from TX to RX.

I did find number of 10Gb vendors that have 1024 or more as the default size for TX queue.

Thanks,
Yevgeny
