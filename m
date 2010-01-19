From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ucc_geth: Fix full TX queue processing
Date: Tue, 19 Jan 2010 02:00:38 -0800 (PST)
Message-ID: <20100119.020038.152864417.davem@davemloft.net>
References: <20100118154750.GA9224@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: B06378@freescale.com, leoli@freescale.com,
	lsorense@csclub.uwaterloo.ca, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50780
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755913Ab0ASKA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 05:00:28 -0500
In-Reply-To: <20100118154750.GA9224@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Mon, 18 Jan 2010 18:47:50 +0300

> From: Jiajun Wu <b06378@freescale.com>
> 
> commit 7583605b6d29f1f7f6fc505b883328089f3485ad ("ucc_geth: Fix empty
> TX queue processing") fixed empty TX queue mishandling, but didn't
> account another corner case: when TX queue becomes full.
> 
> Without this patch the driver will stop transmiting when TX queue
> becomes full since 'bd == ugeth->txBd[txQ]' actually checks for
> two things: queue empty or full.
> 
> Let's better check for NULL skb, which unambiguously signals an empty
> queue.
> 
> Signed-off-by: Jiajun Wu <b06378@freescale.com>
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied.
