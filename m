From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH for-2.6.35] tun: avoid BUG, dump packet on GSO errors
Date: Sat, 24 Jul 2010 20:47:32 -0700 (PDT)
Message-ID: <20100724.204732.112605618.davem@davemloft.net>
References: <20100721143245.GA8423@redhat.com>
	<20100722130512.GA29088@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53447
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750875Ab0GYDrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jul 2010 23:47:15 -0400
In-Reply-To: <20100722130512.GA29088@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 22 Jul 2010 21:05:12 +0800

> Michael S. Tsirkin <mst@redhat.com> wrote:
>> There are still some LRO cards that cause GSO errors in tun,
>> and BUG on this is an unfriendly way to tell the admin
>> to disable LRO.
>> 
>> Further, experience shows we might have more GSO bugs lurking.
>> See https://bugzilla.kernel.org/show_bug.cgi?id=16413
>> as a recent example.
>> dumping a packet will make it easier to figure it out.
>> 
>> Replace BUG with warning+dump+drop the packet to make
>> GSO errors in tun less critical and easier to debug.
>> 
>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>> Tested-by: Alex Unigovsky <unik@compot.ru>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks everyone.
