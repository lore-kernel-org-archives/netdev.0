From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: order addresses by scope
Date: Mon, 10 Jul 2006 15:26:24 -0700 (PDT)
Message-ID: <20060710.152624.14224431.davem@davemloft.net>
References: <4489BA9A.9050508@hp.com>
	<20060710.150045.128593827.davem@davemloft.net>
	<20060710.181816.38918735.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63381
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965278AbWGJWZn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 18:25:43 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060710.181816.38918735.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Mon, 10 Jul 2006 18:18:16 -0400 (EDT)

> In article <20060710.150045.128593827.davem@davemloft.net> (at Mon, 10 Jul 2006 15:00:45 -0700 (PDT)), David Miller <davem@davemloft.net> says:
> 
> > > If IPv6 addresses are ordered by scope, then ipv6_dev_get_saddr() can 
> > > break-out of the device addr_list for() loop when the candidate source 
> > > address scope is less than the destination address scope.
> > > 
> > > Signed-off-by: Brian Haley <brian.haley@hp.com>
> > 
> > This patch looks fine to me, it's an optimization and not a
> > correctness issue.
> > 
> > But I'd like an ACK from an ipv6 developer, such as Yoshifuji, before
> > adding this patch.
> 
> I agree, too.
> Note: People should not depend on the order of addresses.
> 
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Thank you for reviewing, patch applied.
