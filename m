From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] New interface for memory accounting (take 1)
Date: Mon, 31 Dec 2007 15:01:28 -0800 (PST)
Message-ID: <20071231.150128.155158970.davem@davemloft.net>
References: <47775B25.7020401@redhat.com>
	<20071230.233413.117211235.davem@davemloft.net>
	<47790811.9080004@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haoki@redhat.com, herbert@gondor.apana.org.au,
	vladislav.yasevich@hp.com, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, tyasui@redhat.com,
	mhiramat@redhat.com, satoshi.oshima.fk@hitachi.com,
	billfink@mindspring.com, andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38693
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751467AbXLaXBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 18:01:30 -0500
In-Reply-To: <47790811.9080004@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 31 Dec 2007 16:17:37 +0100

> Could you add the following patch, because it apparently was lost
> during the battle :)
> 
> Thank you
> 
> [PATCH] use SK_MEM_QUANTUM_SHIFT in __sk_mem_reclaim()
> 
> Avoid an expensive divide (as done in commit 
> 18030477e70a826b91608aee40a987bbd368fec6 but lost in commit 
> 23821d2653111d20e75472c8c5003df1a55309a8)
> 
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Sigh :-/

Thanks for catching this Eric, patch applied.
