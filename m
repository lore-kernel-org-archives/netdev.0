From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] ipv6: order addresses by scope
Date: Mon, 10 Jul 2006 18:18:16 -0400 (EDT)
Message-ID: <20060710.181816.38918735.yoshfuji@linux-ipv6.org>
References: <4489BA9A.9050508@hp.com>
	<20060710.150045.128593827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:39697 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S964926AbWGJWSN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 18:18:13 -0400
To: davem@davemloft.net
In-Reply-To: <20060710.150045.128593827.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20060710.150045.128593827.davem@davemloft.net> (at Mon, 10 Jul 2006 15:00:45 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> > If IPv6 addresses are ordered by scope, then ipv6_dev_get_saddr() can 
> > break-out of the device addr_list for() loop when the candidate source 
> > address scope is less than the destination address scope.
> > 
> > Signed-off-by: Brian Haley <brian.haley@hp.com>
> 
> This patch looks fine to me, it's an optimization and not a
> correctness issue.
> 
> But I'd like an ACK from an ipv6 developer, such as Yoshifuji, before
> adding this patch.

I agree, too.
Note: People should not depend on the order of addresses.

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji

