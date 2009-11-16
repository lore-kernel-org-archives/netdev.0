From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Optimize hard_start_xmit() return
 checking
Date: Sun, 15 Nov 2009 22:09:21 -0800 (PST)
Message-ID: <20091115.220921.65235245.davem@davemloft.net>
References: <20091115172012.GA2976@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33255
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751214AbZKPGJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 01:09:05 -0500
In-Reply-To: <20091115172012.GA2976@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 15 Nov 2009 18:20:12 +0100

> Recent changes in the TX error propagation require additional checking
> and masking of values returned from hard_start_xmit(), mainly to
> separate cases where skb was consumed. This aim can be simplified by
> changing the order of NETDEV_TX and NET_XMIT codes, because the latter
> are treated similarly to negative (ERRNO) values.
> 
> After this change much simpler dev_xmit_complete() is also used in
> sch_direct_xmit(), so it is moved to netdevice.h.
> 
> Additionally NET_RX definitions in netdevice.h are moved up from
> between TX codes to avoid confusion while reading the TX comment.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Looks good, applied, thanks!
