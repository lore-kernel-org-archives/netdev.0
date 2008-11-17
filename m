From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: af_unix can make unix_nr_socks visbile in /proc
Date: Mon, 17 Nov 2008 00:01:03 -0800 (PST)
Message-ID: <20081117.000103.264682817.davem@davemloft.net>
References: <4921240D.9000409@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50616
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751630AbYKQIBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 03:01:03 -0500
In-Reply-To: <4921240D.9000409@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 17 Nov 2008 08:58:05 +0100

> Currently, /proc/net/protocols displays socket counts only for TCP/TCPv6
> protocols
> 
> We can provide unix_nr_socks for free here, this counter being
> already maintained in af_unix
> 
> Before patch :
> 
> # grep UNIX /proc/net/protocols
> UNIX       428     -1      -1   NI       0   yes  kernel
> 
> After patch :
> 
> # grep UNIX /proc/net/protocols
> UNIX       428     98      -1   NI       0   yes  kernel
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks a lot Eric.
