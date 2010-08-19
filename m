From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: simplify flags for tx timestamping
Date: Thu, 19 Aug 2010 00:07:39 -0700 (PDT)
Message-ID: <20100819.000739.184824510.davem@davemloft.net>
References: <4C6ADC02.5000305@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: patrick.ohly@intel.com, netdev@vger.kernel.org
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52950
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751886Ab0HSHHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 03:07:21 -0400
In-Reply-To: <4C6ADC02.5000305@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Tue, 17 Aug 2010 20:59:14 +0200

> This patch removes the abstraction introduced by the union skb_shared_tx in
> the shared skb data.
> 
> The access of the different union elements at several places led to some
> confusion about accessing the shared tx_flags e.g. in skb_orphan_try().
> 
>     http://marc.info/?l=linux-netdev&m=128084897415886&w=2
> 
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

Applied, thanks for following up on this Oliver.
