From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: netif_tx_queue_stopped too expensive
Date: Tue, 28 Apr 2009 04:44:06 -0700 (PDT)
Message-ID: <20090428.044406.95326734.davem@davemloft.net>
References: <49F6CD24.5080000@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49239
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750733AbZD1LoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 07:44:15 -0400
In-Reply-To: <49F6CD24.5080000@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 28 Apr 2009 11:32:20 +0200

> netif_tx_queue_stopped(txq) is most of the time false.
> 
> Yet its cost is very expensive on SMP.
 ...
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Fair enough, applied to net-next-2.6, thanks Eric.
