From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 3/5] netdev: add tracepoints to netdev layer
Date: Mon, 23 Aug 2010 20:53:00 -0700 (PDT)
Message-ID: <20100823.205300.84370703.davem@davemloft.net>
References: <4C72422C.5070102@jp.fujitsu.com>
	<4C72431E.3000901@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaneshige.kenji@jp.fujitsu.com, izumi.taku@jp.fujitsu.com,
	kosaki.motohiro@jp.fujitsu.com, nhorman@tuxdriver.com,
	laijs@cn.fujitsu.com, scott.a.mcmillan@intel.com,
	rostedt@goodmis.org, eric.dumazet@gmail.com, fweisbec@gmail.com,
	mathieu.desnoyers@polymtl.ca
To: sanagi.koki@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49027
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752871Ab0HXDwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 23:52:43 -0400
In-Reply-To: <4C72431E.3000901@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Date: Mon, 23 Aug 2010 18:45:02 +0900

> This patch adds tracepoint to dev_queue_xmit, dev_hard_start_xmit, netif_rx and
> netif_receive_skb. These tracepoints help you to monitor network driver's
> input/output.
> 
>           <idle>-0     [001] 112447.902030: netif_rx: dev=eth1 skbaddr=f3ef0900 len=84
>           <idle>-0     [001] 112447.902039: netif_receive_skb: dev=eth1 skbaddr=f3ef0900 len=84
>             sshd-6828  [000] 112447.903257: net_dev_queue: dev=eth4 skbaddr=f3fca538 len=226
>             sshd-6828  [000] 112447.903260: net_dev_xmit: dev=eth4 skbaddr=f3fca538 len=226 rc=0
> 
> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>

Acked-by: David S. Miller <davem@davemloft.net>
