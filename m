From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: avoid one atomic operation in skb_clone()
Date: Wed, 01 Oct 2014 21:27:48 -0400 (EDT)
Message-ID: <20141001.212748.2188434550553073923.davem@davemloft.net>
References: <1412202435.16704.68.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38681 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752741AbaJBB1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 21:27:51 -0400
In-Reply-To: <1412202435.16704.68.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Oct 2014 15:27:15 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Fast clone cloning can actually avoid an atomic_inc(), if we
> guarantee prior clone_ref value is 1.
> 
> This requires a change kfree_skbmem(), to perform the 
> atomic_dec_and_test() on clone_ref before setting fclone to
> SKB_FCLONE_UNAVAILABLE.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
