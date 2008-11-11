From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix /proc/net/snmp as memory corruptor
Date: Mon, 10 Nov 2008 21:43:25 -0800 (PST)
Message-ID: <20081110.214325.84371467.davem@davemloft.net>
References: <20081108025256.GA16001@x200.localdomain>
	<20081108033618.GA27960@x200.localdomain>
	<4915295B.4050102@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, snakebyte@gmx.de, netdev@vger.kernel.org,
	alan@lxorguk.ukuu.org.uk
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51049
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752210AbYKKFn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 00:43:26 -0500
In-Reply-To: <4915295B.4050102@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 08 Nov 2008 06:53:31 +0100

> [PATCH] net: fix /proc/net/snmp as memory corruptor
> 
> icmpmsg_put() can happily corrupt kernel memory, using a static
> table and forgetting to reset an array index in a loop.
> 
> Remove the static array since its not safe without proper locking.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

I've applied this version of the fix.

Thanks!
