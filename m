From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: UDP-Lite and /proc/net/snmp
Date: Sat, 10 Nov 2007 22:32:43 +0900 (JST)
Message-ID: <20071110.223243.114494952.yoshfuji@linux-ipv6.org>
References: <20071110131428.GA6447@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:39800 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930AbXKJNcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Nov 2007 08:32:36 -0500
In-Reply-To: <20071110131428.GA6447@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20071110131428.GA6447@gondor.apana.org.au> (at Sat, 10 Nov 2007 21:14:29 +0800), Herbert Xu <herbert@gondor.apana.org.au> says:

> It looks like the addition of UDP-Lite has upset netstat:
> 
> $ netstat -s
> Ip:
:
> Udp:
>     30 packets received
>     0 packets to unknown port received.
>     0 packet receive errors
>     17 packets sent
> UdpLite:
> error parsing /proc/net/snmp: Success
> $
> 
> Should we remove it again or let it stay this time?

Hmm?  netstat 1.42 (net-tools 1.60) seems fine.
Which netstat are you using?

--yoshfuji
