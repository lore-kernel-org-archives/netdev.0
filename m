From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp6: don't move IP6CB before xfrm6_policy_check()
Date: Mon, 22 Dec 2014 16:48:44 -0500 (EST)
Message-ID: <20141222.164844.47766171021564150.davem@davemloft.net>
References: <1419264939.11185.18.camel@edumazet-glaptop2.roam.corp.google.com>
	<1419268968-4136-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43832 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755153AbaLVVsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 16:48:47 -0500
In-Reply-To: <1419268968-4136-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 22 Dec 2014 18:22:48 +0100

> When xfrm6_policy_check() is used, _decode_session6() is called after some
> intermediate functions. This function uses IP6CB(), thus TCP_SKB_CB() must be
> prepared after the call of xfrm6_policy_check().
> 
> Before this patch, scenarii with IPv6 + TCP + IPsec Transport are broken.
> 
> Fixes: 971f10eca186 ("tcp: better TCP_SKB_CB layout to reduce cache line misses")
> Reported-by: Huaibin Wang <huaibin.wang@6wind.com>
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied and queued up for -stable, thanks everyone.
