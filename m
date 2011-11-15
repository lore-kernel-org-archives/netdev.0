From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: [PATCH] ipv4: fix for ip_options_rcv_srr() daddr update.
Date: Tue, 15 Nov 2011 15:51:29 +0800
Message-ID: <4EC21A01.90702@cn.fujitsu.com>
References: <4EC1FB5D.80705@cn.fujitsu.com>	<20111115.013527.2095109012737872896.davem@davemloft.net>	<4EC21427.9080008@cn.fujitsu.com> <20111115.022835.551127337110017182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62524 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751272Ab1KOHvN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 02:51:13 -0500
In-Reply-To: <20111115.022835.551127337110017182.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Li Wei <lw@cn.fujitsu.com>
> Date: Tue, 15 Nov 2011 15:26:31 +0800
> 
>> My question, in ip_forward() and ip_forward_options() rt is there, why not
>> we just use it?
> 
> Because I'm trying to eliminate all accesses to rt->rt_dst because
> when I remove the routing cache, routes will be shared.  One 'rt'
> will refer to many specific destination addresses.
> 
> 
Sorry, I can't understand what you said, can you make it more clear?

I think in ip_forward(), we need 'rt' to forward skb, until this skb has been 
forwarded we hold a reference to it in skb, We can use rt->rt_dst safely, It
is an ordinary __be32 not a reference.
