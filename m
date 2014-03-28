From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v2 3/3] ipv6: fix checkpatch errors of "foo*"
 and "foo * bar"
Date: Thu, 27 Mar 2014 22:47:25 -0700
Message-ID: <1395985645.31134.2.camel@joe-AO722>
References: <1395979624-8544-1-git-send-email-wangyufen@huawei.com>
	 <1395979624-8544-4-git-send-email-wangyufen@huawei.com>
	 <1395980521.19009.8.camel@joe-AO722>
	 <20140328.014012.963819707045886028.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: wangyufen@huawei.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0164.hostedemail.com ([216.40.44.164]:50696 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750885AbaC1Fr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 01:47:29 -0400
In-Reply-To: <20140328.014012.963819707045886028.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-28 at 01:40 -0400, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Thu, 27 Mar 2014 21:22:01 -0700
> 
> > On Fri, 2014-03-28 at 12:07 +0800, Wangyufen wrote:
> > []
> >> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
> > []
> >> @@ -143,7 +143,7 @@ static __inline__ __be32 addr_bit_set(const void *token, int fn_bit)
> >>  	       addr[fn_bit >> 5];
> >>  }
> > 
> > Perhaps all the __inline__ uses could be changed to inline too.
> 
> Or rather, deleted completely, this is a *.c file after all.

Maybe right.  There are a lot though just in net/

$ git ls-files net | grep "\.c$" | \
  xargs grep -Pw "_{0,2}inline_{0,2}" | wc -l
1512
