From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] ipv6 mcast: Fix incorrect use of pskb_may_pull().
Date: Wed, 26 Dec 2012 12:11:27 +0900
Message-ID: <50DA6ADF.5020003@linux-ipv6.org>
References: <50D9BB19.2080801@linux-ipv6.org> <1356456420.20133.15020.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Eric Dumazet <erdnetdev@gmail.com>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39582 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752807Ab2LZDLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Dec 2012 22:11:31 -0500
In-Reply-To: <1356456420.20133.15020.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> On Tue, 2012-12-25 at 23:41 +0900, YOSHIFUJI Hideaki wrote:
> 
>> +	if (!pskb_may_pull(skb, skb->len))
>> +		return -EINVAL;
>> +
> 
> skb_linearize(skb) might be more explicit then.

Oh, I've found errors, so I'll respin.

--yoshfuji
