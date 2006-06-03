From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [Bug 6421] kernel 2.6.10-2.6.16 on alpha:
 arch/alpha/kernel/io.c, iowrite16_rep() BUG_ON((unsigned long)src & 0x1)
 triggered
Date: Sat, 03 Jun 2006 19:51:23 +0900 (JST)
Message-ID: <20060603.195123.77471511.yoshfuji@linux-ipv6.org>
References: <200605271731.k4RHVJTb018158@fire-2.osdl.org>
	<20060603095442.GA373@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:36108 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751382AbWFCKus
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jun 2006 06:50:48 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060603095442.GA373@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20060603095442.GA373@gondor.apana.org.au> (at Sat, 3 Jun 2006 19:54:42 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> [TCP]: Avoid skb_pull if possible when trimming head
> 
> Trimming the head of an skb by calling skb_pull can cause the packet
> to become unaligned if the length pulled is odd.  Since the length is
> entirely arbitrary for a FIN packet carrying data, this is actually
> quite common.

I think that people will start thinking why we cannot
skb_pull(skb, len) if skb_headlen(skb) == len; some comment needed...

--yoshfuji
