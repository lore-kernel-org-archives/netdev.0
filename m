From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v5 00/11] ipv6: Only create RTF_CACHE route after
 encountering pmtu exception
Date: Tue, 26 May 2015 23:20:53 +0200
Message-ID: <1432675253.2338285.278763921.042325B0@webmail.messagingengine.com>
References: <1432353366-2296465-1-git-send-email-kafai@fb.com>
 <20150525.133445.1964566940924227163.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Julian Anastasov <ja@ssi.bg>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Kernel-team@fb.com
To: David Miller <davem@davemloft.net>, kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:38586 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751859AbbEZVU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 17:20:58 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 64D2E20A1E
	for <netdev@vger.kernel.org>; Tue, 26 May 2015 17:20:53 -0400 (EDT)
In-Reply-To: <20150525.133445.1964566940924227163.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 25, 2015, at 19:34, David Miller wrote:
> From: Martin KaFai Lau <kafai@fb.com>
> Date: Fri, 22 May 2015 20:55:55 -0700
> 
> > This series is to avoid creating a RTF_CACHE route whenever we are consulting
> > the fib6 tree with a new destination.  Instead, only create RTF_CACHE route
> > when we see a pmtu exception.
> 
> Looks great, nice work.
> 
> Series applied to net-next, thanks!

I also went over the changes to the last version and such, albeit a bit
late:
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
