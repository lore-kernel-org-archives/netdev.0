From: David Miller <davem@davemloft.net>
Subject: Re: mlx4_en: Fix loss of promiscuity
Date: Sun, 27 Mar 2011 18:43:29 -0700 (PDT)
Message-ID: <20110327.184329.233689279.davem@davemloft.net>
References: <20110327110126.GA25595@gondor.apana.org.au>
	<953B660C027164448AE903364AC447D20705E115@mtldag01.mtl.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52363
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752569Ab1C1BoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 21:44:08 -0400
In-Reply-To: <953B660C027164448AE903364AC447D20705E115@mtldag01.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Sun, 27 Mar 2011 11:21:37 +0000

>> mlx4_en: Fix loss of promiscuity
>> 
>> The mlx4_en driver uses the combination stop_port/start_port in a number of places.  Unfortunately that causes any promiscuous mode settings on the hardware to be lost.
>> 
>> This patch fixes that problem.
>> 
>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>> 
> 
> Thank you Herbert,
> This patch does fix the problem you reported on.

Please ACK patches explicitly by stating:

Acked-by: ...

in your reply so that your feedback automatically ends up in the tree
when I apply his patch.
