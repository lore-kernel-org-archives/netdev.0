From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 BUG] VLAN out of service ?
Date: Thu, 25 Dec 2008 16:45:32 -0800 (PST)
Message-ID: <20081225.164532.250950190.davem@davemloft.net>
References: <494BFA0A.8010202@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44652
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752198AbYLZApa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 19:45:30 -0500
In-Reply-To: <494BFA0A.8010202@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 19 Dec 2008 20:46:18 +0100

> [PATCH] vlan: fix convertion to net_device_ops
> 
> commit 656299f706e52e0409733d704c2761f1b12d6954
> (vlan: convert to net_device_ops) added a net_device_ops
> with a NULL ndo_start_xmit field.
> 
> This gives a crash in dev_hard_start_xmit()
> 
> Fix it using two net_device_ops structures, one for hwaccel vlan,
> one for non hwaccel vlan.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks a lot Eric.
