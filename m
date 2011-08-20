From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: br2684: Fix oops due to skb->dev being NULL
Date: Sat, 20 Aug 2011 14:13:30 -0700 (PDT)
Message-ID: <20110820.141330.1983433503669425489.davem@davemloft.net>
References: <1313791460-13652-1-git-send-email-daniel.schwierzeck@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: daniel.schwierzeck@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33820 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752726Ab1HTVNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2011 17:13:39 -0400
In-Reply-To: <1313791460-13652-1-git-send-email-daniel.schwierzeck@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Schwierzeck <daniel.schwierzeck@googlemail.com>
Date: Sat, 20 Aug 2011 00:04:20 +0200

> This oops have been already fixed with commit
> 
>     27141666b69f535a4d63d7bc6d9e84ee5032f82a
> 
>     atm: [br2684] Fix oops due to skb->dev being NULL
> 
>     It happens that if a packet arrives in a VC between the call to open it on
>     the hardware and the call to change the backend to br2684, br2684_regvcc
>     processes the packet and oopses dereferencing skb->dev because it is
>     NULL before the call to br2684_push().
> 
> but have been introduced again with commit
> 
>     b6211ae7f2e56837c6a4849316396d1535606e90
> 
>     atm: Use SKB queue and list helpers instead of doing it by-hand.
> 
> Signed-off-by: Daniel Schwierzeck <daniel.schwierzeck@googlemail.com>

Applied, thanks!
