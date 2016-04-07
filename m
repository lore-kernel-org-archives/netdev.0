From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] lockdep: provide always true lockdep_is_held stub if
 lockdep disabled
Date: Fri, 8 Apr 2016 01:21:24 +0200
Message-ID: <5706EB74.9050108@stressinduktion.org>
References: <1460070722-18652-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:39984 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751818AbcDGXV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 19:21:28 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id BFF41203AC
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2016 19:21:27 -0400 (EDT)
In-Reply-To: <1460070722-18652-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.04.2016 01:12, Hannes Frederic Sowa wrote:
> I need this to provide a generic lockdep_sock_is_held function which can
> be easily used in the kernel without using ifdef PROVEN macros.
>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> Hello Peter and Ingo,
>
> if it is possible coud this go in via the net-tree, as this problem is
> visible there already? Would be happy to get a review.

I take this patch back, as some call sites test if the lock is 
definitely not held. I come up with a better approach.
