From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 00/11] ipv6: Only create RTF_CACHE route
 after encountering pmtu exception
Date: Mon, 25 May 2015 13:34:45 -0400 (EDT)
Message-ID: <20150525.133445.1964566940924227163.davem@davemloft.net>
References: <1432353366-2296465-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org, ja@ssi.bg,
	steffen.klassert@secunet.com, Kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45508 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894AbbEYRes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 13:34:48 -0400
In-Reply-To: <1432353366-2296465-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Fri, 22 May 2015 20:55:55 -0700

> This series is to avoid creating a RTF_CACHE route whenever we are consulting
> the fib6 tree with a new destination.  Instead, only create RTF_CACHE route
> when we see a pmtu exception.

Looks great, nice work.

Series applied to net-next, thanks!
