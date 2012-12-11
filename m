From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: use netdev_alloc_frag()
Date: Tue, 11 Dec 2012 12:51:03 -0500 (EST)
Message-ID: <20121211.125103.1869709000760345113.davem@davemloft.net>
References: <1355177766.27891.68.camel@edumazet-glaptop>
	<504C9EFCA2D0054393414C9CB605C37F1BFC4273@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41042 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753735Ab2LKRvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 12:51:05 -0500
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F1BFC4273@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Mon, 10 Dec 2012 22:57:44 +0000

>> -----Original Message-----
>> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
>> Sent: Tuesday, December 11, 2012 12:16 AM
>> To: David Miller
>> Cc: netdev; Eilon Greenstein; Dmitry Kravkov
>> Subject: [PATCH net-next] bnx2x: use netdev_alloc_frag()
>> 
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> Using netdev_alloc_frag() instead of kmalloc() permits better GRO or
>> TCP coalescing behavior, as skb_gro_receive() doesn't have to fallback
>> to frag_list overhead.
>> 
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Dmitry Kravkov <dmitry@broadcom.com>
>> Cc: Eilon Greenstein <eilong@broadcom.com>
> 
> Thanks a lot, Eric!
> 
> Acked-by: Dmitry Kravkov <dmitry@broadcom.com>

Applied.
