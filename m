From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net-next v2 0/8] ipv6: clean up locking code in anycast
 and mcast
Date: Fri, 12 Sep 2014 22:40:28 +0200
Message-ID: <1410554428.2970.21.camel@localhost>
References: <1410474916-21873-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:38215 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752368AbaILUkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 16:40:31 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id 684D120C83
	for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 16:40:30 -0400 (EDT)
In-Reply-To: <1410474916-21873-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Do, 2014-09-11 at 15:35 -0700, Cong Wang wrote:
> This patchset cleans up the locking code in anycast.c and mcast.c
> and makes the refcount code more readable.
> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> 
> v1 -> v2:
> * refactor some code and make it in a separated patch
> * update comments
> 
> Cong Wang (8):
>   ipv6: drop useless rcu_read_lock() in anycast
>   ipv6: remove ipv6_sk_ac_lock
>   ipv6: clean up ipv6_dev_ac_inc()
>   ipv6: refactor __ipv6_dev_ac_inc()
>   ipv6: drop ipv6_sk_mc_lock in mcast
>   ipv6: drop some rcu_read_lock in mcast
>   ipv6: update the comment in mcast.c
>   ipv6: refactor ipv6_dev_mc_inc()

All reviewed, looks good, thanks for following up on this!

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
