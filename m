From: David Miller <davem@davemloft.net>
Subject: Re: [TCP] Avoid a divide in tcp_mtu_probing()
Date: Fri, 21 Dec 2007 05:58:46 -0800 (PST)
Message-ID: <20071221.055846.184095429.davem@davemloft.net>
References: <20071221143241.4aa9f672.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38958
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754947AbXLUN6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 08:58:47 -0500
In-Reply-To: <20071221143241.4aa9f672.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 21 Dec 2007 14:32:41 +0100

> tcp_mtu_to_mss() being signed, compiler might emit an integer divide
> to compute tcp_mtu_to_mss()/2 .
> 
> Using a right shift is OK here and less expensive.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
