From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] xfrm: add rcu grace period in
 xfrm_policy_destroy()
Date: Fri, 11 Dec 2015 19:22:29 -0500 (EST)
Message-ID: <20151211.192229.424897034366170918.davem@davemloft.net>
References: <1449588122-13941-1-git-send-email-edumazet@google.com>
	<20151208.225829.122422778076120961.davem@davemloft.net>
	<20151210123422.GA29565@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753142AbbLLAWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 19:22:31 -0500
In-Reply-To: <20151210123422.GA29565@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 10 Dec 2015 13:34:22 +0100

> On Tue, Dec 08, 2015 at 10:58:29PM -0500, David Miller wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> Date: Tue,  8 Dec 2015 07:22:01 -0800
>> 
>> > We will soon switch sk->sk_policy[] to RCU protection,
>> > as SYNACK packets are sent while listener socket is not locked.
>> > 
>> > This patch simply adds RCU grace period before struct xfrm_policy
>> > freeing, and the corresponding rcu_head in struct xfrm_policy.
>> > 
>> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>> 
>> I'll give Steffen an opportunity to review these two patches.
> 
> Looks ok and survived some tests with socket policies.
> 
> If you want to take these direct into the net tree:
> 
> Acked-by: Steffen Klassert <steffen.klassert@secunet.com>

Thanks! I just did exactly that.
