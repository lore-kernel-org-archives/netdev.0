From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] tcp listener refactoring part 15
Date: Mon, 23 Mar 2015 16:52:56 -0400 (EDT)
Message-ID: <20150323.165256.1010799920148836791.davem@davemloft.net>
References: <1427044945-32608-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753167AbbCWUw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 16:52:58 -0400
In-Reply-To: <1427044945-32608-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Sun, 22 Mar 2015 10:22:17 -0700

> I am trying to make the final patch pushing request socks into ehash
> as small as possible. In this patch series, I made various adjustments
> for the SYNACK generation, allowing me to reach 1 Mpps SYNACK in my
> stress test (still hitting LISTENER spinlock of course, and the syn_wait
> spinlock)
> 
> I also converted the ICMP handlers a bit ahead of time :
> 
> They no longer need to get the LISTENER socket, and can use
> only a lookup in ehash table. No big deal if we ignore ICMP
> for requests socks before the final steps.

Series applied, thanks Eric.
