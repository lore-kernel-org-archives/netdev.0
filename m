From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] xfrm: Make xfrm_state timer monotonic
Date: Thu, 15 Aug 2013 14:23:34 -0700 (PDT)
Message-ID: <20130815.142334.1736006937556027032.davem@davemloft.net>
References: <1376552946-18967-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086Ab3HOVXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 17:23:35 -0400
In-Reply-To: <1376552946-18967-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Thu, 15 Aug 2013 15:49:06 +0800

> xfrm_state timer should be independent of system clock change,
> so switch to CLOCK_BOOTTIME base which is not only monotonic but
> also counting suspend time.
> 
> Thus issue reported in commit: 9e0d57fd6dad37d72a3ca6db00ca8c76f2215454
> ("xfrm: SAD entries do not expire correctly after suspend-resume")
> could ALSO be avoided.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>
> 
> v2: Use CLOCK_BOOTTIME to count suspend time, but still monotonic.

This seems like a good fix:

Acked-by: David S. Miller <davem@davemloft.net>
