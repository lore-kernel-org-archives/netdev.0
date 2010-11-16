From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] vlan: lockless transmit path
Date: Tue, 16 Nov 2010 11:24:24 -0800 (PST)
Message-ID: <20101116.112424.102532013.davem@davemloft.net>
References: <1289468520.17691.1018.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47960
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753636Ab0KPTYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 14:24:00 -0500
In-Reply-To: <1289468520.17691.1018.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 11 Nov 2010 10:42:00 +0100

> vlan is a stacked device, like tunnels. We should use the lockless
> mechanism we are using in tunnels and loopback.
> 
> This patch completely removes locking in TX path.
> 
> tx stat counters are added into existing percpu stat structure, renamed
> from vlan_rx_stats to vlan_pcpu_stats.
> 
> Note : this partially reverts commit 2e59af3dcbdf (vlan: multiqueue vlan
> device)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, although there were some conflicts since John Fastabend
made some vlan changes recently.

Please double check my work.
